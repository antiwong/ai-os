# Local models (Ollama on the Radeon 780M)

Ollama runs as a **user** service (`config/systemd/user/ollama.service`, linked by `05-link-dotfiles.sh`):
`systemctl --user status ollama`. API: `http://127.0.0.1:11434`. Models live in `~/.ollama/models`.
It uses the Vulkan backend on the integrated GPU (`OLLAMA_VULKAN=1`, `OLLAMA_IGPU_ENABLE=1`); one model is loaded at a time and unloads after 5 minutes idle.

## Hardware limits
14 GB RAM shared with the iGPU (about 6-7 GB usually free). Plan for **3-4B models at Q4 (about 2-2.5 GB)**; 7B (about 4.7 GB) only with other apps closed. 70B is not possible.

## Measured
`qwen2.5-coder:3b`, short code prompt: CPU 78 prompt / 20 gen tokens/s; iGPU 141 prompt / 26.5 gen tokens/s (100% GPU). Not a benchmark of quality.

## Installed
| Model | Size | Use |
|---|---|---|
| `qwen2.5-coder:3b` | 2.2 GB | quick code questions, completions |

## Commands
```
ollama run qwen2.5-coder:3b       # chat
ollama ps                         # loaded model and CPU/GPU split
ollama pull <model>               # add one; ollama rm <model> to remove
```
Candidates when you want more: a 4B general model (e.g. `qwen3:4b`), `qwen2.5-coder:7b` (tight on memory).

## Notes
- Packages: `ollama` + `ollama-vulkan` (the ROCm build is not needed for Vulkan).
- The packaged system service (`ollama.service` under `/usr/lib/systemd`) stays disabled; the user service avoids needing `sudo` and keeps models in your home.
