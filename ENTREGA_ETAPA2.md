# Etapa 2 — Atividade 02
## Registro do avanço do desenvolvimento do Projeto Integrador

**Aluno:** João Pedro Tavares Vicente
**Projeto:** Voz Autista v2.0 — Comunicador Assistivo
**Repositório:** https://github.com/joao-ped/Project_auts
**Data de envio:** 05/06/2026 (prazo: 08/06/2026)

---

## 1. Evidências de progresso

O projeto está em fase avançada de desenvolvimento, com toda a parte de **software, documentação, simulação e modelagem 3D concluída**. Falta apenas a montagem física do hardware, que está agendada para a próxima etapa.

### 1.1 Código firmware (Arduino) — CONCLUÍDO
- **Arquivo:** `voz_autista_maker_code.ino` (589 linhas)
- **Funcionalidades implementadas:**
  - 7 categorias com 35 palavras (Necessidades, Sentimentos, Ações, Comidas, Lugares, Pessoas, Saúde)
  - Frases compostas (empilha até 5 palavras)
  - Controle de volume via potenciômetro analógico (A0)
  - Monitor de bateria com ícone no LCD (A1, divisor de tensão)
  - Feedback tátil por motor de vibração (D7, transistor 2N2222)
  - Modo sleep após 2 min de inatividade
  - Auto-detecção do endereço I2C do LCD (0x27, 0x3F, 0x20, 0x38)
  - Seção dedicada de configuração para personalizar categorias

### 1.2 Documentação técnica — CONCLUÍDA
- **README.md** — visão geral do projeto
- **GUIA_IMPLEMENTACAO.md** (26 KB) — guia completo de implementação
- **Manual de Montagem Visual** (`manual_montagem_visual.html`, 125 KB) — 10 etapas com:
  - Plano físico do case 3D (vista superior da base + tampa, em escala 1.6 mm/px)
  - Vistas laterais (esquerda e direita) com cotas de todas as aberturas
  - Esquemático elétrico completo do circuito real v2.0
  - Tabela de pinos
  - Lista de materiais com 18 componentes e quantidades
  - Checklist de testes e seção de troubleshooting

### 1.3 Simulação no Wokwi — CONCLUÍDA
- **Pasta `wokwi_simulacao/`** com:
  - `diagram.json` (18 partes, 27 conexões) — Arduino, LCD I2C, 5 botões, buzzer, LED de vibração, 2 potenciômetros, resistores
  - `sketch.ino` adaptado para simulação (mesmo da pinagem do hardware real)
  - `abrir_no_wokwi.html` — página assistente que copia o circuito para o Wokwi em 3 cliques
  - `COMO_USAR.md` — 5 métodos de import documentados

### 1.4 Simulador no navegador — CONCLUÍDO
- **`simulador.html`** — versão interativa do comunicador que roda no navegador usando Text-to-Speech (Web Speech API). Permite demonstrar o produto sem precisar do hardware físico.

### 1.5 Apresentação — CONCLUÍDA
- **`apresentacao.html`** — slides interativos navegáveis com visão geral, motivação, demonstração, hardware e diferenciais.

### 1.6 Case 3D — MODELO PRONTO PARA IMPRESSÃO
- **`case_3d/case_voz_autista.scad`** (OpenSCAD paramétrico, 456 linhas)
- Dimensões internas: **170 × 110 × 42 mm**
- **Base** com: pilares M3, berço para bateria 18650, suporte do motor de vibração, aberturas para USB Arduino, jack de alimentação, micro-USB TP4056, chave on/off, slot do microSD, furo do potenciômetro
- **Tampa** com: janela do LCD, 5 furos para botões (Ø14 mm), grade do speaker (Ø40 mm), labels em relevo (CAT+, CAT-, PAL+, PAL-, VOZ)
- **`visualizar_case_3d.html`** — viewer 3D no navegador para inspecionar o modelo

### 1.7 Site do projeto (GitHub Pages) — CONCLUÍDO
- **`index.html`** — landing page hub com 6 cards (Apresentação, Manual, Simulador, Wokwi, Case 3D, Código Arduino)
- **`.nojekyll`** configurado para hospedagem
- URL prevista: https://joao-ped.github.io/Project_auts/

### 1.8 Histórico de commits no GitHub
```
1ca7604  Corrige erros no manual: SD card, cores de fios e descrição do circuito
6859cd7  Adiciona orçamento detalhado e circuito esquemático real
a9f2ad4  Adiciona simulador interativo com TTS e melhora apresentação
7869abe  Adiciona apresentação HTML interativa do projeto
8c693d9  v2.0: README completo, case 3D corrigido para impressão, viewer 3D
16ca89a  Commit1
6fbea46  Initial commit
```
(Mais commits serão adicionados nos próximos dias com as melhorias recentes do manual de montagem, do hub index.html e da página assistente do Wokwi.)

### 1.9 Orçamento detalhado — DEFINIDO
Custo total estimado: **R$ 128,00** (componentes principais)

---

## 2. Roadmap — Próximos passos

### 2.1 Curto prazo (junho/2026)
- [ ] **Push do repositório** com `index.html`, `.nojekyll` e melhorias do manual
- [ ] **Ativar GitHub Pages** (Settings → Pages → Source: main / root)
- [ ] **Imprimir o case 3D** (base + tampa) em PLA ou PETG
- [ ] **Comprar os componentes físicos** (Arduino Uno, LCD I2C, DFPlayer Mini, alto-falante, botões, potenciômetro, motor de vibração, bateria 18650, TP4056, transistor 2N2222, diodo 1N4148, resistores, fios, chave slide, parafusos)

### 2.2 Médio prazo (julho/2026)
- [ ] **Montagem do hardware** conforme as 10 etapas do manual visual
- [ ] **Gravação do firmware** no Arduino
- [ ] **Preparação do microSD** com 35 arquivos MP3 organizados em 7 pastas (/01/ a /07/)
- [ ] **Testes em bancada** — validar cada botão, navegação, áudio, vibração, volume, bateria
- [ ] **Ajustes finais no case** se necessário (tolerâncias de impressão)

### 2.3 Longo prazo (agosto/2026 em diante)
- [ ] **Teste com usuários reais** — pessoas autistas não-verbais e suas famílias/cuidadores
- [ ] **Coleta de feedback** — usabilidade, conforto, palavras mais úteis
- [ ] **Iteração do produto** — adaptar categorias e palavras conforme uso real
- [ ] **Documentar resultados** dos testes para apresentação final
- [ ] **Considerar futuras versões** — bluetooth, app companheiro, mais palavras, gravação de voz personalizada

### 2.4 Entregáveis do grupo até a próxima etapa
1. Site no ar (GitHub Pages) com index hub
2. Vídeo curto de demonstração do simulador no navegador
3. Fotos da impressão 3D do case
4. Lista de compra confirmada com fornecedores

---

**Status geral:** Projeto está dentro do cronograma. A fase de software/documentação está 100% concluída, antecipando trabalho que originalmente seria feito junto com a montagem. Isso permite focar na próxima etapa exclusivamente em hardware e testes.
