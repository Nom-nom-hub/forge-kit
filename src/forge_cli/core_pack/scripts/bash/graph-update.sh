#!/usr/bin/env bash
# FORGE: Update Graph Edge Index
# Scans .forge/ directories and builds the edge relationship index
# Usage: ./scripts/bash/graph-update.sh

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
FORGE_DIR="$ROOT_DIR/.forge"
EDGES_FILE="$FORGE_DIR/edges.json"

if [[ ! -d "$FORGE_DIR" ]]; then
  echo '{"error": "FORGE not initialized. Run forge init first."}'
  exit 1
fi

mkdir -p "$FORGE_DIR/graph"

# Build edge index by scanning artifact links
python3 -c "
import json, os, glob, yaml

edges = []
forge_dir = '$FORGE_DIR'

# Scan each artifact directory
for art_type in ['signals', 'hypotheses', 'decisions', 'features', 'experiments', 'releases']:
    dir_path = os.path.join(forge_dir, art_type)
    if not os.path.isdir(dir_path):
        continue
    
    for f in glob.glob(os.path.join(dir_path, '*.yaml')):
        try:
            with open(f) as fh:
                data = yaml.safe_load(fh)
            if not data:
                continue
            
            artifact_id = data.get('id', '')
            if not artifact_id:
                continue
            
            # Extract links from the artifact
            links = data.get('links', {})
            for link_type, linked_ids in links.items():
                if isinstance(linked_ids, list):
                    for linked_id in linked_ids:
                        if linked_id:
                            edges.append({
                                'source': artifact_id,
                                'target': linked_id,
                                'type': link_type.upper()
                            })
            
            # Check for hypothesis/signals/decisions references
            for ref_field in ['signals', 'hypotheses', 'decisions', 'features']:
                refs = data.get(ref_field, [])
                if isinstance(refs, list):
                    for ref_id in refs:
                        if ref_id:
                            edges.append({
                                'source': artifact_id,
                                'target': ref_id,
                                'type': 'REFERENCES'
                            })
            
            # Check nested references
            if 'hypothesis' in data and data['hypothesis']:
                edges.append({
                    'source': artifact_id,
                    'target': data['hypothesis'],
                    'type': 'TESTS' if art_type == 'features' else 'REFERENCES'
                })
            
            if 'feature' in data and data['feature']:
                edges.append({
                    'source': artifact_id,
                    'target': data['feature'],
                    'type': 'SHAPED_BY'
                })
        except Exception:
            pass

# Deduplicate
seen = set()
unique_edges = []
for e in edges:
    key = (e['source'], e['target'], e['type'])
    if key not in seen:
        seen.add(key)
        unique_edges.append(e)

output = {
    'version': '1.0.0',
    'edges': unique_edges,
    'last_updated': __import__('datetime').datetime.utcnow().isoformat() + 'Z',
    'edge_count': len(unique_edges)
}

with open('$EDGES_FILE', 'w') as f:
    json.dump(output, f, indent=2)

print(json.dumps(output, indent=2))
" 2>/dev/null || echo "{\"warning\": \"Python/YAML not available, using existing edge index\"}"
