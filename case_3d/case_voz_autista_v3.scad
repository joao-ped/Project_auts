// ============================================================
// Case "Voz Autista" v3.0 - Comunicador Assistivo (AAC)
// Para impressão 3D (FDM - PLA ou PETG)
// ============================================================
// Abrir com OpenSCAD (https://openscad.org)
// Exportar: F6 (Render) > File > Export as STL
// Use os arquivos exportar_*.scad para gerar cada peça isolada.
// ============================================================
//
// CONFIGURAÇÕES DE IMPRESSÃO RECOMENDADAS:
//   - Material: PLA ou PETG (PETG mais resistente a impacto/calor)
//   - Bico: 0.4 mm | Camada: 0.2 mm | Preenchimento: 25% (giroide)
//   - BASE: imprime em pé (fundo na mesa), SEM suporte.
//   - TAMPA: imprime INVERTIDA (face dos botões na mesa).
//     Necessita suporte APENAS sob a aba inclinada do LCD
//     (cunha de 12°, volume pequeno, remoção fácil).
//   - TAMPA DA BATERIA / KNOB / ADAPTADOR FALAR: sem suporte.
//   - Tempo estimado: ~5h base + ~4h tampa + ~30min miúdos
//
// FORMATO GERAL: "console de mesa" em cunha
//   - Externo: 150 (X) x 100 (Y) x 40 mm na frente,
//     subindo a ~47.7 mm na traseira (face do LCD inclinada 12°).
//   - Cantos arredondados r=10, superfícies pensadas para
//     acabamento fosco (lixar leve ou imprimir com PLA fosco):
//     baixa reflexão e menos estímulo visual (design AAC).
//
// ============================================================
// MAPA INTERNO (vista superior, coordenadas ABSOLUTAS em mm,
// origem no canto externo frente-esquerda; parede = 2.5,
// portanto o interior vai de (2.5, 2.5) a (147.5, 97.5)):
//
//  y=100 ┌─[chave on/off]────[slot SD DFPlayer]────────────────┐
//        │(o) x22-36, recuada       x101-115            (o)    │ <- orelhas cordão Ø4
//        │ ┌────────┐┌───────┐┌─────┐  ╔═════════╗ ┌─────────┐ │    (externas, traseira)
//        │ │PERFBOARD││MT3608 ││motor│  ║   LCD   ║ │DFPlayer │ │
//        │ │ driver  ││boost  ││coin │  ║ (pende  ║ │  Mini   │ │
//   y=80 │ │10-30,   ││34-52, ││Ø10  │  ║da tampa ║ │97.5-118 │ │  ┌──────────┐
//        │ │80-90    ││80-91  ││52,72│  ║inclinada║ │77-97.5  │ │  │ BATERIA  │
//        ├─┴────────┐└───────┘└─────┘  ║  12°)   ║ └─────────┘ │  │  18650   │
//        │ TP4056   │                  ╚═════════╝             │  │ x122-143 │
//   y=60 │ 6.5-32.5,│   ··· tampa começa a inclinar em y=64 ···│  │ y24.5-92.5│
//        │ 62.5-79.5│  ╭─────────────────╮                     │  │          │
//        ├──────────┘  │   ALTO-FALANTE  │  [CAT-]    [CAT+]   │  │ (tampa de│
//        │┌────────────┤   Ø40 no FUNDO  │   x63.5     x91.5   │  │  troca no│
//   y=40 ││ ARDUINO UNO│   grade p/baixo │        y=54.5       │  │  FUNDO,  │
//  [USB] ││ x6.5-75.1  │   centro        │  [PAL-]    [PAL+]   │  │  2 clipes)│
//  [jack]││ y5.5-58.9  │   (97.5, 40.5)  │   x63.5     x91.5   │  └──────────┘
//        ││ pilares 3mm╰────────┬────────╯        y=35         │ <- pot. volume
//  [µUSB]││ topo z=18           │                              │    knob Ø20
//   y=20 │└─────────────────────┘     ( FALAR Ø14, anel Ø24 )  │    y=15.5, z=20
//        │                              x77.5  y=17.5          │
//   y=0  └──────────────────────────────────────────────────────┘
//         x=0                                              x=150
//
// ALTURAS (z, a partir do fundo externo):
//   fundo 0-2.5 | piso interno 2.5 | base até 26.5 | tampa 26.5-40 (frente)
//   topo inclinado 40 -> 47.7 (y=64 -> y=100)
//   Arduino: pilar 3 + placa c/ USB 15 = topo z 20.5
//   Botões: corpo 15 mm pendurado da tampa = z 25 -> 40 (frente)
//   Bateria: Ø18.6 deitada no poço, topo z ~21.5
//   LCD + backpack I2C: pende 25 mm da face inclinada (livre por baixo)
//
// VALIDAÇÃO DE COLISÕES: ver CHANGELOG_V3.md (tabela completa).
// ============================================================

// ===================== PARÂMETROS GERAIS =====================

wall       = 2.5;    // Espessura de parede
ext_w      = 150;    // Largura externa (X)
ext_d      = 100;    // Profundidade externa (Y)
front_h    = 40;     // Altura externa na frente (face dos botões)
slope_ang  = 12;     // Inclinação da face do LCD (graus)
slope_y0   = 64;     // Y absoluto onde o topo começa a subir
corner_r   = 10;     // Raio dos cantos (acessibilidade: sem arestas)
tolerance  = 0.3;    // Folga de encaixe entre peças

base_h     = 26.5;   // Altura externa da base (fundo 2.5 + parede 24)
rear_h     = front_h + (ext_d - slope_y0) * tan(slope_ang); // ~47.65

eps        = 0.1;    // Offset anti z-fighting em booleans
$fn        = 48;

// ===================== COMPONENTES (coordenadas ABSOLUTAS) =====================

// --- Arduino Uno R3 ---
ard_x = 6.5;  ard_y = 5.5;          // Canto da PCB
ard_w = 68.6; ard_d = 53.4;
// Furos de montagem CANÔNICOS do Uno R3 (relativos ao canto da PCB)
// Fonte: desenho mecânico oficial Arduino Uno (spacing 1.27mm grid)
ard_holes = [[15.24, 2.54], [15.24, 50.80], [66.04, 7.62], [66.04, 35.56]];
ard_pillar_h = 3;                    // Pilar baixo: deixa folga p/ botões acima

// Aberturas lateral ESQUERDA (Arduino) - centro Y e tamanhos
usb_yc  = ard_y + 40;  usb_w = 14;  usb_h = 13; usb_z = 6;   // USB-B
jack_yc = ard_y + 10;  jack_w = 13; jack_h = 12; jack_z = 5; // Jack 5.5/2.1

// --- LCD 16x2 + backpack I2C (montado na face inclinada da tampa) ---
lcd_win_w = 73;  lcd_win_h = 26;     // Janela (ativa real: 71.4 x 24.3)
lcd_pcb_w = 81;  lcd_pcb_h = 37;     // Rebaixo p/ PCB 80x36
lcd_cx    = 75;                       // Centro X da janela (centro do case)
lcd_s0    = 5;                        // Início da janela ao longo da rampa (mm)
lcd_hole_dx = 75; lcd_hole_dy = 31;  // Furos de montagem do LCD (Ø3)

// --- DFPlayer Mini (SD pela parede TRASEIRA) ---
dfp_x = 97.5; dfp_y = 77; dfp_w = 20.5; dfp_d = 20.5;
sd_w = 14; sd_z = 4; sd_h = 5.5;     // Abertura do cartão SD

// --- Botões: layout 2+2+1 (acessibilidade: FALAR maior e isolado) ---
btn_hole_d   = 14;     // Furo p/ botão 12mm (folga)
btn_ring_w   = 1.5;    // Largura do anel tátil
btn_ring_h   = 1.2;    // ALTURA do anel tátil (alto: evita toque acidental)
btn_falar    = [77.5, 17.5];                       // FALAR (preto) - Ø anel 24
btn_pal      = [[63.5, 35], [91.5, 35]];           // PAL- (azul) | PAL+ (verde)
btn_cat      = [[63.5, 54.5], [91.5, 54.5]];       // CAT- (amarelo) | CAT+ (vermelho)
relief_h     = 0.8;    // Altura dos pictogramas/textos em relevo

// --- Alto-falante 40mm (montado no FUNDO, grade para baixo) ---
spk_cx = 97.5; spk_cy = 40.5; spk_d = 40; spk_t = 5.5;

// --- Bateria 18650 (poço vertical à direita, tampa de troca no fundo) ---
bat_x0 = 122;  bat_x1 = 143;     // Cavidade (21 mm p/ Ø18.6 + folga)
bat_y0 = 24.5; bat_y1 = 92.5;    // Cavidade (68 mm p/ 65 + terminais)
bat_wall = 2.5;                  // Parede do poço
bat_wall_h = 21;                 // Altura das paredes do poço
door_open = [124, 28, 17, 60];   // Abertura no piso [x, y, w, d]
door_rec  = [121, 25, 23, 66];   // Rebaixo externo p/ tampa [x, y, w, d]
door_rec_depth = 1.3;            // Profundidade do rebaixo
door_t    = 1.2;                 // Espessura da tampa da bateria

// --- TP4056 (micro-USB pela parede esquerda) ---
tp_x = 6.5; tp_y = 62.5; tp_w = 26; tp_d = 17;
tp_usb_w = 10; tp_usb_z = 4; tp_usb_h = 5;

// --- MT3608 boost (v3.0: rail 5V estável a partir da 18650) ---
mt_x = 34.5; mt_y = 80.5; mt_w = 17; mt_d = 11;

// --- Perfboard do driver (2N2222 + 1N4148 + resistores + caps) ---
pb_x = 10.5; pb_y = 80; pb_w = 20; pb_d = 10;

// --- Motor de vibração coin ---
vib_cx = 52.5; vib_cy = 72.5; vib_d = 10; vib_t = 3;

// --- Potenciômetro de volume (parede DIREITA, frente) ---
pot_yc = 15.5; pot_zc = 20; pot_hole_d = 7.5;

// --- Chave on/off (parede TRASEIRA, recuada em moldura) ---
sw_x0 = 22.5; sw_w = 13.4; sw_z0 = 12; sw_h = 5.6;
sw_guard = 2.5;                  // Moldura externa que recua a chave

// --- Furos do cordão (orelhas externas traseiras, reforçadas) ---
lan_hole_d = 4.5;
lan_tabs_x = [14, 136];          // Centros X das orelhas
lan_tab_w = 14; lan_tab_d = 8; lan_tab_t = 5;
lan_tab_z = 32;                  // Altura do centro da orelha

// --- Pés de borracha (rebaixos no fundo) ---
foot_d = 10; foot_depth = 1.5; foot_inset = 14;

// --- Parafusos da tampa (2x M3, diagonais) ---
screw_pos = [[139.5, 10.5], [70, 93]];
screw_r = 1.7; screw_pillar_r = 4;

// ===================== QUAL PEÇA RENDERIZAR =====================

render_base         = true;
render_lid          = true;
render_battery_door = true;
render_knob         = false;  // Knob estriado Ø20 do potenciômetro
render_falar_cap    = false;  // Adaptador Ø18 p/ o botão FALAR

explode = 25;  // Separação visual entre base e tampa (0 = montado)

// ===================== MÓDULOS BÁSICOS =====================

// Retângulo arredondado 2D
module rounded_rect(w, d, r) {
    offset(r) square([w - 2*r, d - 2*r]);
}

// Caixa arredondada 3D (cantos verticais arredondados)
module rounded_box(w, d, h, r) {
    translate([r, r, 0]) linear_extrude(h) rounded_rect(w, d, r);
}

// Pilar de montagem com furo
module mounting_pillar(h, hole_r, pr) {
    difference() {
        cylinder(h=h, r=pr);
        translate([0, 0, -eps]) cylinder(h=h + 2*eps, r=hole_r, $fn=16);
    }
}

// Posiciona children() no sistema de coordenadas da RAMPA do LCD:
//   x local = x absoluto ; y local = distância ao longo da rampa (s);
//   z local = normal para fora da face inclinada.
module on_slope() {
    translate([0, slope_y0, front_h]) rotate([slope_ang, 0, 0]) children();
}

// Corte do topo da tampa: tudo acima da face frontal plana (z=front_h, y<slope_y0)
// e acima do plano inclinado (y>slope_y0). zoff desloca os planos para baixo
// (usado para escavar a cavidade interna paralela).
module top_cut(zoff = 0) {
    // Plano frontal plano
    translate([-1, -1, front_h - zoff])
        cube([ext_w + 2, slope_y0 + 1 + eps, 40]);
    // Plano inclinado (cunha traseira)
    translate([0, slope_y0, front_h - zoff])
        rotate([slope_ang, 0, 0])
        translate([-1, -eps, 0])
        cube([ext_w + 2, 60, 40]);
}

// Grade de furos para o alto-falante
module speaker_grille(r_max, hole_d = 2.5, spacing = 5) {
    n = floor(2 * r_max / spacing);
    for (ix = [-n/2 : n/2], iy = [-n/2 : n/2]) {
        px = ix * spacing; py = iy * spacing;
        if (sqrt(px*px + py*py) < r_max)
            translate([px, py, 0])
            cylinder(h=wall * 3, d=hole_d, center=true, $fn=16);
    }
}

// Clipes em L para PCBs pequenas (DFPlayer, TP4056...) - chanfrados
module pcb_clips(w, d, clip_h = 6, lip = 1.4, t = 1.8) {
    for (side = [0, 1]) {
        sx = side == 0 ? -t : w;
        translate([sx, 0, 0]) {
            cube([t, d, clip_h]);
            // Lábio chanfrado (45°, imprime sem suporte)
            lx = side == 0 ? t : -lip;
            translate([lx, 0, clip_h - lip])
                rotate([0, side == 0 ? 0 : 0, 0])
                hull() {
                    translate([side == 0 ? 0 : 0, 0, 0])
                        cube([lip, d, lip]);
                    translate([side == 0 ? -lip : lip, 0, lip - eps])
                        cube([lip, d, eps]);
                }
        }
    }
}

// Cantos de retenção p/ PCB sem furos (MT3608, perfboard)
module pcb_corners(w, d, h = 4, t = 1.6, arm = 5) {
    for (c = [[0,0,0], [w,0,90], [w,d,180], [0,d,270]])
        translate([c[0], c[1], 0]) rotate([0, 0, c[2]])
            union() {
                translate([-t, -t, 0]) cube([arm + t, t, h]);
                translate([-t, -t, 0]) cube([t, arm + t, h]);
            }
}

// Seta em relevo (triângulo + haste), apontando para +Y; rotacionar conforme uso
module relief_arrow(size = 6) {
    linear_extrude(relief_h) union() {
        polygon([[-size/2, 0], [size/2, 0], [0, size * 0.7]]);
        translate([-size/6, -size * 0.55]) square([size/3, size * 0.55]);
    }
}

// Balão de fala em relevo (símbolo do botão FALAR)
module relief_balloon(d = 11) {
    linear_extrude(relief_h) union() {
        difference() {
            circle(d=d);
            circle(d=d - 2.4);
        }
        // Rabinho do balão
        polygon([[-d*0.15, -d*0.32], [d*0.18, -d*0.32], [-d*0.28, -d*0.62]]);
    }
}

// Texto em relevo padrão
module relief_text(s, size = 3.4) {
    linear_extrude(relief_h)
        text(s, size=size, halign="center", valign="center",
             font="Liberation Sans:style=Bold");
}

// ===================== BASE =====================

module base() {
    difference() {
        union() {
            // Casca externa
            difference() {
                rounded_box(ext_w, ext_d, base_h, corner_r);
                translate([wall, wall, wall])
                    rounded_box(ext_w - 2*wall, ext_d - 2*wall,
                                base_h, corner_r - wall/2);
            }

            // --- Moldura de proteção da chave on/off (recuo externo) ---
            // Em vez de rebaixar a parede (2.5mm não permite), uma moldura
            // externa de 2.5mm faz a alavanca ficar recuada: não desliga
            // sem querer (requisito de acessibilidade).
            translate([sw_x0 - sw_guard - 2, ext_d - eps, sw_z0 - sw_guard - 1])
                difference() {
                    cube([sw_w + 2*sw_guard + 4, sw_guard + eps, sw_h + 2*sw_guard + 2]);
                    translate([sw_guard, -eps, sw_guard])
                        cube([sw_w + 4, sw_guard + 3, sw_h + 2]);
                }
        }

        // ---------- ABERTURAS ----------
        // USB-B do Arduino (esquerda) - cuidador faz upload sem abrir
        translate([-eps, usb_yc - usb_w/2, wall + usb_z])
            cube([wall + 2*eps, usb_w, usb_h]);
        // Jack de alimentação do Arduino (esquerda)
        translate([-eps, jack_yc - jack_w/2, wall + jack_z])
            cube([wall + 2*eps, jack_w, jack_h]);
        // micro-USB do TP4056 (esquerda) - recarga sem abrir
        translate([-eps, tp_y + (tp_d - tp_usb_w)/2, wall + tp_usb_z])
            cube([wall + 2*eps, tp_usb_w, tp_usb_h]);
        // Slot SD do DFPlayer (traseira)
        translate([dfp_x + (dfp_w - sd_w)/2, ext_d - wall - eps, wall + sd_z - 2])
            cube([sd_w, wall + 2*eps, sd_h]);
        // Chave on/off (traseira, dentro da moldura)
        translate([sw_x0, ext_d - wall - eps, sw_z0])
            cube([sw_w, wall + sw_guard + 2*eps, sw_h]);
        // Furo do potenciômetro (direita) + furo anti-rotação
        translate([ext_w - wall - eps, pot_yc, pot_zc])
            rotate([0, 90, 0]) cylinder(h=wall + 2*eps, d=pot_hole_d, $fn=32);

        // ---------- FUNDO ----------
        // Grade do alto-falante (som sai por baixo; pés afastam da mesa)
        translate([spk_cx, spk_cy, wall/2]) speaker_grille(17);
        // Abertura da bateria (tampa de troca)
        translate([door_open[0], door_open[1], -eps])
            cube([door_open[2], door_open[3], wall + 2*eps]);
        // Rebaixo externo p/ a tampa da bateria ficar faceada
        translate([door_rec[0], door_rec[1], -eps])
            cube([door_rec[2], door_rec[3], door_rec_depth + eps]);
        // Entalhe de dedo p/ abrir a tampa
        translate([door_rec[0] + door_rec[2]/2, door_rec[1] - 2, -eps])
            cylinder(h=door_rec_depth + eps, d=12, $fn=32);
        // Rebaixos dos pés de borracha (antiderrapante)
        for (fp = [[foot_inset, foot_inset], [ext_w - foot_inset, foot_inset],
                   [foot_inset, ext_d - foot_inset], [ext_w - foot_inset, ext_d - foot_inset]])
            translate([fp[0], fp[1], -eps])
                cylinder(h=foot_depth + eps, d=foot_d, $fn=24);
        // Ventilação sob o Arduino/TP4056
        for (vx = [0:5], vy = [0:3])
            translate([ard_x + 14 + vx*7, ard_y + 12 + vy*7, -eps])
                cylinder(h=wall + 2*eps, d=2.5, $fn=12);
        // Selo em baixo-relevo + área lisa p/ etiqueta com nome do usuário
        translate([44, ext_d - 14, -eps]) linear_extrude(0.7)
            text("VOZ AUTISTA v3.0", size=5, halign="center", valign="center",
                 font="Liberation Sans:style=Bold");
        translate([16, 62, -eps]) cube([52, 24, 0.5]); // área da etiqueta
    }

    // ---------- ESTRUTURAS INTERNAS ----------
    // Pilares do Arduino (furos canônicos, parafuso M2.5 auto-atarraxante)
    for (h = ard_holes)
        translate([ard_x + h[0], ard_y + h[1], wall])
            mounting_pillar(ard_pillar_h, 1.1, 3);

    // Poço da bateria 18650 (paredes; o fundo é a própria tampa removível)
    difference() {
        union() {
            translate([bat_x0 - bat_wall, bat_y0 - bat_wall, wall - eps])
                cube([bat_wall, bat_y1 - bat_y0 + 2*bat_wall, bat_wall_h]);
            translate([bat_x1, bat_y0 - bat_wall, wall - eps])
                cube([bat_wall, bat_y1 - bat_y0 + 2*bat_wall, bat_wall_h]);
            translate([bat_x0 - bat_wall, bat_y0 - bat_wall, wall - eps])
                cube([bat_x1 - bat_x0 + 2*bat_wall, bat_wall, bat_wall_h]);
            translate([bat_x0 - bat_wall, bat_y1, wall - eps])
                cube([bat_x1 - bat_x0 + 2*bat_wall, bat_wall, bat_wall_h]);
        }
        // Passagens de fio no topo das paredes curtas
        translate([(bat_x0 + bat_x1)/2 - 2.5, bat_y0 - bat_wall - eps, wall + bat_wall_h - 6])
            cube([5, bat_wall + 2*eps, 7]);
        translate([(bat_x0 + bat_x1)/2 - 2.5, bat_y1 - eps, wall + bat_wall_h - 6])
            cube([5, bat_wall + 2*eps, 7]);
    }

    // Suporte do alto-falante: 3 postes curvos (em vez de anel completo,
    // para não colidir com Arduino à esquerda e poço da bateria à direita)
    for (a = [90, 210, 330])
        translate([spk_cx, spk_cy, wall])
            rotate([0, 0, a])
            difference() {
                translate([0, spk_d/2 + 0.3, 0]) union() {
                    cylinder(h=spk_t + 0.5, d=6);
                    // Lábio chanfrado que segura a borda do falante
                    translate([0, 0, spk_t + 0.5 - eps])
                        cylinder(h=1.2, d1=6, d2=8.5);
                }
                translate([0, 0, -eps]) cylinder(h=spk_t + 0.6, d=spk_d + 0.6);
            }

    // Clipes do DFPlayer Mini
    translate([dfp_x, dfp_y, wall]) pcb_clips(dfp_w, dfp_d, 6, 1.4, 1.8);
    // Clipes do TP4056
    translate([tp_x, tp_y, wall]) pcb_clips(tp_w, tp_d, 4.5, 1.2, 1.6);
    // Cantos do MT3608 (boost v3.0)
    translate([mt_x, mt_y, wall]) pcb_corners(mt_w, mt_d, 4);
    // Cantos da perfboard do driver (2N2222 + diodo + resistores + caps)
    translate([pb_x, pb_y, wall]) pcb_corners(pb_w, pb_d, 4);
    // Suporte anelar do motor de vibração
    translate([vib_cx, vib_cy, wall])
        difference() {
            cylinder(h=vib_t + 1, d=vib_d + 3, $fn=32);
            translate([0, 0, 1]) cylinder(h=vib_t + 1, d=vib_d + 0.5, $fn=32);
            translate([0, -1.5, 0.5]) cube([vib_d, 3, vib_t + 2]);
        }

    // Nervuras de reforço (case vai cair no chão - uso real por crianças)
    // Parede frontal:
    for (rx = [40, 75, 110])
        translate([rx - 0.75, wall - eps, wall])
            hull() {
                cube([1.5, 3, base_h - wall - 4]);
                cube([1.5, 6, 1]); // gusset chanfrado, imprime sem suporte
            }
    // Parede traseira (evitando SD x101-115, chave x22-36, DFPlayer x>97.5):
    for (rx = [45, 75])
        translate([rx - 0.75, ext_d - wall - 3 + eps, wall])
            hull() {
                translate([0, 0, 0]) cube([1.5, 3, base_h - wall - 4]);
                translate([0, -3, 0]) cube([1.5, 3, 1]);
            }

    // Pilares dos 2 parafusos M3 da tampa (diagonais)
    for (p = screw_pos)
        translate([p[0], p[1], wall])
            mounting_pillar(base_h - wall, 1.35, screw_pillar_r);

    // Borda de encaixe (rim) para a tampa
    rim_t = 2; rim_h = 3;
    translate([wall + tolerance, wall + tolerance, base_h - eps])
        difference() {
            rounded_box(ext_w - 2*wall - 2*tolerance, ext_d - 2*wall - 2*tolerance,
                        rim_h, corner_r - wall);
            translate([rim_t, rim_t, -eps])
                rounded_box(ext_w - 2*wall - 2*tolerance - 2*rim_t,
                            ext_d - 2*wall - 2*tolerance - 2*rim_t,
                            rim_h + 2*eps, corner_r - wall - 1);
            // Recortes do rim onde passam os pilares de parafuso
            for (p = screw_pos)
                translate([p[0] - wall - tolerance, p[1] - wall - tolerance, -eps])
                    cylinder(h=rim_h + 2*eps, r=screw_pillar_r + 0.4);
        }
    // Bumps de clique (snap) no rim
    for (b = [[35, wall + tolerance], [110, wall + tolerance],
              [35, ext_d - wall - tolerance], [110, ext_d - wall - tolerance],
              [wall + tolerance, 50], [ext_w - wall - tolerance, 50]])
        translate([b[0], b[1], base_h + 1.5]) sphere(r=0.8, $fn=12);
}

// ===================== TAMPA =====================

module lid() {
    difference() {
        union() {
            // Corpo: casca em cunha
            difference() {
                // Sólido externo
                difference() {
                    translate([0, 0, base_h])
                        rounded_box(ext_w, ext_d, rear_h - base_h + 5, corner_r);
                    top_cut(0);
                }
                // Cavidade interna (paredes 2.5, teto 2.5 perpendicular)
                difference() {
                    translate([wall, wall, base_h - 1])
                        rounded_box(ext_w - 2*wall, ext_d - 2*wall,
                                    rear_h, corner_r - wall/2);
                    top_cut(wall / cos(slope_ang)); // ~2.56 vertical
                }
            }

            // Orelhas externas do cordão (traseira, reforçadas, chanfro 45°)
            for (tx = lan_tabs_x)
                translate([tx - lan_tab_w/2, ext_d - eps, lan_tab_z - lan_tab_t/2])
                    hull() {
                        cube([lan_tab_w, lan_tab_d, lan_tab_t]);
                        // chanfro inferior (imprime de cabeça p/ baixo sem suporte)
                        translate([2, 0, -2]) cube([lan_tab_w - 4, eps, lan_tab_t]);
                    }
        }

        // ---------- FUROS DOS BOTÕES (layout 2+2+1) ----------
        for (b = concat([btn_falar], btn_pal, btn_cat))
            translate([b[0], b[1], front_h - wall - 2])
                cylinder(h=wall + 6, d=btn_hole_d, $fn=40);

        // ---------- JANELA DO LCD (na face inclinada) ----------
        on_slope() translate([lcd_cx - lcd_win_w/2, lcd_s0, -10])
            cube([lcd_win_w, lcd_win_h, 20]);
        // Rebaixo interno p/ a PCB do LCD ficar faceada
        on_slope() translate([lcd_cx - lcd_pcb_w/2, lcd_s0 - (lcd_pcb_h - lcd_win_h)/2,
                              -wall - 1.8])
            cube([lcd_pcb_w, lcd_pcb_h, 1.8 + eps]);

        // ---------- FUROS DO CORDÃO (verticais, nas orelhas) ----------
        for (tx = lan_tabs_x)
            translate([tx, ext_d + lan_tab_d/2, lan_tab_z - lan_tab_t/2 - 3])
                cylinder(h=lan_tab_t + 8, d=lan_hole_d, $fn=24);

        // ---------- FUROS DOS PARAFUSOS M3 (com escareado) ----------
        for (p = screw_pos) {
            translate([p[0], p[1], base_h - 2])
                cylinder(h=rear_h, r=screw_r, $fn=20);
            // Escareado a partir da face externa local
            zf = p[1] > slope_y0 ? front_h + (p[1] - slope_y0)*tan(slope_ang) : front_h;
            translate([p[0], p[1], zf - 2.2])
                cylinder(h=10, d=6.8, $fn=24);
        }

        // ---------- CANALETA no anel tátil p/ pintura/insert colorido ----------
        // (FDM mono-cor: cada botão recebe canaleta de 0.6mm p/ tinta
        //  acrílica ou anel de filamento colorido colado)
        for (b = concat(btn_pal, btn_cat))
            translate([b[0], b[1], front_h + btn_ring_h - 0.6])
                difference() {
                    cylinder(h=0.7, d=btn_hole_d + 2*1.0 + 2*btn_ring_w);
                    translate([0,0,-eps]) cylinder(h=1, d=btn_hole_d + 2*1.0 + 0.6);
                }
        translate([btn_falar[0], btn_falar[1], front_h + btn_ring_h - 0.6])
            difference() {
                cylinder(h=0.7, d=22.5);
                translate([0,0,-eps]) cylinder(h=1, d=19);
            }
    }

    // ---------- ANÉIS TÁTEIS EM RELEVO (1.2mm) ----------
    // Anel alto ao redor de cada botão: guia o dedo e evita toque acidental
    // (usuários com baixa coordenação motora - design AAC)
    for (b = concat(btn_pal, btn_cat))
        translate([b[0], b[1], front_h])
            difference() {
                cylinder(h=btn_ring_h, d=btn_hole_d + 2 + 2*btn_ring_w, $fn=40);
                translate([0, 0, -eps])
                    cylinder(h=btn_ring_h + 2*eps, d=btn_hole_d + 2, $fn=40);
            }
    // FALAR: anel maior (Ø24) - botão principal, destacado
    translate([btn_falar[0], btn_falar[1], front_h])
        difference() {
            cylinder(h=btn_ring_h, d=24, $fn=48);
            translate([0, 0, -eps]) cylinder(h=btn_ring_h + 2*eps, d=20, $fn=48);
        }

    // ---------- PICTOGRAMAS + LABELS EM RELEVO ----------
    // CAT: ▼ à esquerda, ▲ à direita, label central
    translate([48.5, 54.5, front_h]) rotate([0,0,180]) relief_arrow(6);
    translate([101.5, 54.5, front_h]) relief_arrow(6);
    translate([75, 54.5, front_h]) relief_text("CAT", 3.2);
    // PAL: ◀ à esquerda, ▶ à direita, label central
    translate([48.5, 35, front_h]) rotate([0,0,90]) relief_arrow(6);
    translate([101.5, 35, front_h]) rotate([0,0,-90]) relief_arrow(6);
    translate([75, 35, front_h]) relief_text("PAL", 3.2);
    // FALAR: balão de fala à esquerda + label à direita
    translate([55, 17.5, front_h]) relief_balloon(11);
    translate([98, 17.5, front_h]) relief_text("FALAR", 3.6);

    // ---------- ESTRUTURAS INTERNAS DA TAMPA ----------
    // Bosses do LCD (4x, perpendiculares à rampa, parafuso M3 auto-atarraxante)
    on_slope()
        for (dx = [-lcd_hole_dx/2, lcd_hole_dx/2],
             dy = [-lcd_hole_dy/2, lcd_hole_dy/2])
            translate([lcd_cx + dx, lcd_s0 + lcd_win_h/2 + dy, -wall - 6])
                difference() {
                    cylinder(h=6 + eps, d=6.5, $fn=24);
                    translate([0, 0, -eps]) cylinder(h=5, d=2.5, $fn=16);
                }

    // Nervuras sob a placa frontal (entre as fileiras de botões)
    for (ry = [26, 44.5])
        translate([20, ry - 0.75, front_h - wall - 4 + eps])
            cube([110, 1.5, 4]);

    // Saia interna (skirt): desce 3mm por fora do rim da base
    skirt_h = 3.5;
    difference() {
        translate([wall + 2*tolerance + 2, wall + 2*tolerance + 2, base_h - skirt_h])
            rounded_box(ext_w - 2*wall - 4*tolerance - 4,
                        ext_d - 2*wall - 4*tolerance - 4,
                        skirt_h + 1, corner_r - wall - 1.5);
        translate([wall + 2*tolerance + 3.6, wall + 2*tolerance + 3.6, base_h - skirt_h - eps])
            rounded_box(ext_w - 2*wall - 4*tolerance - 7.2,
                        ext_d - 2*wall - 4*tolerance - 7.2,
                        skirt_h + 1 + 2*eps, corner_r - wall - 2.2);
        // Recortes p/ os pilares de parafuso
        for (p = screw_pos)
            translate([p[0], p[1], base_h - skirt_h - eps])
                cylinder(h=skirt_h + 1.5, r=screw_pillar_r + 0.6);
    }
}

// ===================== TAMPA DA BATERIA =====================
// Placa que fecha o poço da 18650 por baixo. Encaixa no rebaixo externo
// e trava com 2 clipes cantilever chanfrados. Troca sem desmontar o case.

module battery_door() {
    dw = door_rec[2] - 2*tolerance;   // 22.4
    dd = door_rec[3] - 2*tolerance;   // 65.4
    clip_w = 8;

    // Placa
    cube([dw, dd, door_t]);
    // Etiqueta de polaridade em relevo
    translate([dw/2, 8, door_t - eps]) linear_extrude(0.5 + eps)
        text("+", size=5, halign="center", valign="center",
             font="Liberation Sans:style=Bold");
    translate([dw/2, dd - 8, door_t - eps]) linear_extrude(0.5 + eps)
        text("-", size=5, halign="center", valign="center",
             font="Liberation Sans:style=Bold");

    // 2 clipes cantilever (nas extremidades curtas), cabeça chanfrada
    for (end = [0, 1]) {
        my = end == 0 ?
            (door_open[1] - door_rec[1]) + 2 :                       // ~5
            (door_open[1] - door_rec[1]) + door_open[3] - clip_w - 2; // dentro da abertura
        translate([dw/2 - clip_w/2, end == 0 ? my : my, door_t - eps]) {
            // Haste flexível
            cube([clip_w, 1.6, wall - door_rec_depth + door_t + 1.2]);
            // Gancho chanfrado (45° p/ inserir, trava no piso interno)
            translate([0, end == 0 ? 1.6 : -1.2, wall - door_rec_depth + door_t + 1.2 - eps])
                hull() {
                    cube([clip_w, 1.2, eps]);
                    translate([0, end == 0 ? -0 : 0, 0])
                        cube([clip_w, eps, 1.4]);
                }
        }
    }
}

// ===================== KNOB DO POTENCIÔMETRO =====================
// Knob estriado Ø20 impresso junto - fácil de girar (motricidade fina)

module pot_knob() {
    difference() {
        union() {
            cylinder(h=12, d=20, $fn=64);
            // 16 estrias verticais
            for (a = [0:22.5:359])
                rotate([0, 0, a]) translate([10 - 0.6, -0.8, 0])
                    cube([1.2, 1.6, 12]);
            // Indicador de posição
            translate([0, 0, 12 - eps]) linear_extrude(0.8)
                polygon([[-1.2, 4], [1.2, 4], [0, 9]]);
        }
        // Furo do eixo D-shaft 6mm (flat em 4.5)
        translate([0, 0, 2]) difference() {
            cylinder(h=11, d=6.3, $fn=32);
            translate([1.55, -4, 1.9]) cube([3, 8, 12]);
        }
    }
}

// ===================== ADAPTADOR DO BOTÃO FALAR =====================
// Capa Ø18 que pressiona sobre o cap Ø12 do botão preto: aumenta a
// área de toque do botão mais usado (requisito de acessibilidade).

module falar_cap() {
    difference() {
        union() {
            cylinder(h=7, d=18, $fn=64);
            translate([0, 0, 7 - eps]) cylinder(h=1.5, d1=18, d2=15, $fn=64);
        }
        // Encaixe sob pressão no cap original Ø12
        translate([0, 0, -eps]) cylinder(h=4.5, d=12.3, $fn=48);
    }
    // Balão de fala em relevo no topo
    translate([0, 0.5, 8.5 - 2*eps]) relief_balloon(9);
}

// ===================== RENDERIZAÇÃO =====================

if (render_base) color("#7a8ba6", 0.95) base();

if (render_lid)
    color("#9db4cc", 0.9)
    translate([0, 0, explode]) lid();

if (render_battery_door)
    color("#5f7a99", 0.95)
    translate([door_rec[0] + tolerance, door_rec[1] + tolerance, -door_t - 6 - explode/3])
    battery_door();

if (render_knob)
    translate([ext_w + 20, 20, 0]) color("#46627f") pot_knob();

if (render_falar_cap)
    translate([ext_w + 20, 55, 0]) color("#2d3e50") falar_cap();
