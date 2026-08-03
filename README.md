# GOAT Hub — STK

Hub cliente independente criado a partir dos seis logs completos e dos dumps de
`ReplicatedStorage`, `StarterPlayerScripts` e `XxSPIRALxX_xX` fornecidos em
`GOATSTK`.

## Antes de executar

Os IDs foram deixados em `0` de propósito, conforme solicitado. Abra
`Config.lua` e preencha:

```lua
GAME_ID = 123456789,
PLACE_IDS = table.freeze({
    1234567890,
    -- outros PlaceIds do mesmo jogo, se necessario
}),
```

Depois regenere o arquivo único:

```sh
cd /storage/emulated/0/Codigos/GOATSTK/GOATHubSTK
python3 tools/build_bundle.py
```

Enquanto `GAME_ID` ou todos os `PLACE_IDS` estiverem zerados, o bundle encerra
antes de montar módulos, interface ou recursos. Ele também encerra silenciosamente
quando executado fora do jogo/place configurado.

## Execução

- Arquivo único para execução: `Distribution/GOATHubSTK.bundle.lua`.
- Loader remoto opcional: preencha `BUNDLE_URL` em `Loader.lua` com a URL raw do
  bundle e execute `Loader.lua`.
- Código-fonte modular: `GOATHubSTKClient/`.

Reexecutar o bundle é seguro para o próprio Hub: uma instância anterior é parada,
suas conexões/loops/highlights são removidos e a nova interface assume o lugar.

## Recursos

- **Auto Escape** — somente como Survivor; aguarda `workspace.ExitsOpen`, escolhe
  uma saída marcada com a tag `Exit` e atributo `Open`, toca o `Trigger` e faz um
  deslocamento curto pelos dois lados até o servidor confirmar `Escaped`.
- **Kill All** — somente como Killer; seleciona Survivors ativos, posiciona o
  jogador 2,5 studs acima e 1,5 à frente do alvo e usa o
  `Character.Knife.KnifeSlashEvent` respeitando o debounce observado de 0,3 s.
- **Auto Revive** — se o jogador local estiver caído, acompanha um Survivor vivo
  para receber ajuda; caso contrário acompanha jogadores caídos e permanece na
  distância de revive. Nenhum remote de revive foi inventado.
- **Team ESP** — `Highlight` azul para Survivor e vermelho para Killer, atualizado
  em respawn, mudança de time e mudança de `Downed`.
- **Auto Collect Loot** — descobre loot pela tag `Loot`, filho `Border` e atributo
  `Loot` no spawn pai; observa novas tags para recolher também os respawns.
- **Auto Fugir do Killer** — como Survivor, mede a distância configurável do
  Killer e escolhe outra superfície válida dentro do modelo do mapa atual. Pontos
  de loot, saída, teto, parede, locker e containers de spawn são excluídos.

Quando mais de um recurso quer mover o personagem, a prioridade é:

```text
Auto Escape > Auto Fugir > Kill All > Auto Revive > Auto Loot
```

## Configuração útil

`Config.lua` concentra IDs, dimensões da interface, distâncias e tempos. A
distância do Auto Fugir também pode ser alterada na interface entre 15 e 120
studs. O padrão é 45.

## Estrutura

```text
GOATHubSTK/
├── Config.lua
├── Loader.lua
├── GOATHubSTKClient/
│   ├── Core/
│   ├── Features/
│   ├── Providers/
│   ├── UI/
│   └── init.lua
├── Distribution/GOATHubSTK.bundle.lua
├── Evidence/
│   ├── analysis.md
│   ├── generated-report.json
│   ├── layout-preview.png
│   └── layout-preview.svg
├── tests/
└── tools/
```

## Verificação local

```sh
python3 tools/analyze_evidence.py
python3 tools/build_bundle.py
python3 tests/check_layout.py
python3 tests/check_static.py
luau tests/layout_spec.luau
find . -name '*.lua' -type f -exec luau-compile --only-parse '{}' ';'
```

Os previews PNG/SVG são representações nativas do cálculo de layout. A validação
final de teleporte, toque, revive e hit deve ser feita dentro de uma sessão real do
jogo, pois depende da autoridade e das verificações do servidor.
