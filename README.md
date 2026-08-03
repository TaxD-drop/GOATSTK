# GOAT Hub — STK

Hub cliente independente criado a partir dos seis logs completos e dos dumps de
`ReplicatedStorage`, `StarterPlayerScripts` e `XxSPIRALxX_xX` fornecidos em
`GOATSTK`.

## Antes de executar

Os IDs são lidos de `Config.lua`. Para alterar o jogo ou adicionar outro place,
edite:

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

Se `GAME_ID` ou todos os `PLACE_IDS` estiverem zerados, o bundle encerra
antes de montar módulos, interface ou recursos. Ele também encerra silenciosamente
quando executado fora do jogo/place configurado.

## Execução

- Arquivo único para execução: `Distribution/GOATHubSTK.bundle.lua`.
- Loader remoto opcional: preencha `BUNDLE_URL` em `Loader.lua` com a URL raw do
  bundle e execute `Loader.lua`.
- Código-fonte modular: `GOATHubSTKClient/`.

Reexecutar o bundle é seguro para o próprio Hub: uma instância anterior é parada,
suas conexões/loops/highlights são removidos e a nova interface assume o lugar.
Os estados dos checkboxes e dos dois campos numéricos são serializados em
`TeleportService` e reaplicados após a nova execução.

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
  `Loot` no spawn pai. Só considera disponível quando encontra uma `BasePart` ou
  `Decal` visual com `Transparency < 0.99` dentro do modelo; continua observando o
  mesmo objeto e novas tags para recolher ambos os tipos de respawn.
- **Auto Fugir do Killer** — como Survivor, mede a distância configurável do
  Killer e escolhe outra superfície válida dentro do modelo do mapa atual. Pontos
  de loot, saída, teto, parede, locker e containers de spawn são excluídos.
- **Gamepasses/Settings locais** — caixas independentes para os 13 atributos de
  `LocalPlayer.Gamepasses` solicitados e para `Settings.double_jump` e
  `Settings.killer_chance_3x`. Ao desmarcar ou fechar o Hub, o valor anterior é
  restaurado. Esses overrides são locais; benefícios validados pelo servidor não
  são garantidos.
- **Remover FOV** — mantém a câmera em `70` enquanto marcado e restaura o valor
  capturado ao desmarcar, inclusive após substituição de `CurrentCamera`.
- **Auto Rejoin** — troca quando o jogador local está sozinho ou quando qualquer
  **outro** jogador possui nível igual/maior ao limite configurado. O nível do
  jogador local nunca é lido para essa decisão.

Não existe fila ou prioridade entre os recursos. Cada automação obedece apenas às
próprias regras de time/estado; se duas automações compatíveis forem ligadas juntas,
a ação mais recente de cada loop pode mover o personagem.

## Configuração útil

`Config.lua` concentra IDs, dimensões da interface, distâncias e tempos. A
distância do Auto Fugir também pode ser alterada na interface entre 15 e 120
studs. O padrão é 45.

O Auto Rejoin lê primeiro o atributo replicado `Level` dos outros jogadores — a
mesma origem usada pelo `PlayerListHandler` para preencher `RankBadge.Level` — e
usa o caminho da GUI como fallback. A lista pública não informa níveis: o Hub
entra em um servidor aleatório com pessoas e vaga, valida os níveis depois de
entrar e troca novamente se necessário. Ele mantém uma fila dos últimos 10 JobIds;
ao adicionar o 11º, remove o mais antigo.

Quando o Hub é iniciado por `Loader.lua`, a URL raw já configurada no Loader é
entregue ao Auto Rejoin. Se o executor oferecer `queue_on_teleport`, o Hub enfileira
essa URL antes de trocar e a repassa novamente no servidor seguinte, permitindo
vários hops consecutivos. Se o bundle for executado diretamente, use o auto-execute
do executor ou preencha `SERVER_HOP.RELOAD_URL` em `Config.lua`.

Ao recriar o Hub, são restaurados Auto Escape, Kill All, Auto Revive, Team ESP,
Auto Loot, Auto Fugir, Remover FOV, todos os overrides de `Gamepasses`/`Settings`,
a distância de fuga, o limite de nível e o próprio Auto Rejoin. Desmarcar uma opção
salva `false`, portanto ela permanece desligada nos servidores seguintes.

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
luau tests/loot_visibility_spec.luau
luau tests/server_hop_policy_spec.luau
find . -name '*.lua' -type f -exec luau-compile --only-parse '{}' ';'
```

Os previews PNG/SVG são representações nativas do cálculo de layout. A validação
final de teleporte, toque, revive e hit deve ser feita dentro de uma sessão real do
jogo, pois depende da autoridade e das verificações do servidor.
