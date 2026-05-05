// ============================================================
// Case "Voz Autista" v2.0 - Dispositivo de Comunicação Assistiva
// Para impressão 3D (FDM - PLA/PETG recomendado)
// ============================================================
// Abrir com OpenSCAD (https://openscad.org)
// Ajuste os parâmetros abaixo conforme necessário
// Para exportar: Design > Render (F6) > File > Export as STL
// ============================================================
//
// Componentes internos:
//   - Arduino Uno (com pilares de montagem)
//   - LCD 16x2 I2C (janela na tampa + suportes)
//   - DFPlayer Mini (abertura SD card lateral direita)
//   - Alto-falante 40mm (grade na tampa)
//   - 5 Botões táteis (furos na tampa com labels)
//   - Bateria 18650 (berço no centro da base)
//   - Módulo TP4056 (abertura micro-USB lateral esquerda)
//   - Potenciômetro de volume (furo lateral direita)
//   - Motor de vibração coin 10mm (suporte na base)
//   - Chave slide on/off (abertura lateral esquerda)
//
// Conectores externos:
//   - USB Arduino (lateral esquerda)
//   - Jack alimentação (lateral esquerda)
//   - Micro-USB carregamento TP4056 (lateral esquerda)
//   - Chave slide liga/desliga (lateral esquerda)
//   - Slot SD card DFPlayer (lateral direita)
//   - Potenciômetro volume (lateral direita)
//
// ============================================================

// ===================== PARÂMETROS GERAIS =====================
// Ajuste estes valores conforme suas medidas reais

// Dimensões internas do case (mm)
case_width  = 170;   // Largura interna
case_depth  = 110;   // Profundidade interna
case_height = 42;    // Altura interna total

wall = 2.5;          // Espessura da parede
corner_r = 8;        // Raio dos cantos arredondados
tolerance = 0.3;     // Folga para encaixe entre peças

// Divisão da altura entre tampa e base
base_height = 30;    // Altura da base (contém componentes)
lid_height  = case_height - base_height; // Altura da tampa

// ===================== COMPONENTES =====================

// --- Arduino Uno (posição relativa ao canto interno inferior-esquerdo) ---
arduino_x = 5;       // Posição X
arduino_y = 5;       // Posição Y
arduino_w = 69;      // Largura da PCB
arduino_d = 54;      // Profundidade da PCB
arduino_h = 12;      // Altura (PCB + componentes embaixo)

// --- LCD 16x2 com I2C (posição no topo/tampa) ---
lcd_x = 45;          // Posição X da janela do LCD
lcd_y = 20;          // Posição Y da janela do LCD
lcd_w = 72;          // Largura da janela visível
lcd_h = 25;          // Altura da janela visível
lcd_pcb_w = 80;      // Largura da PCB do LCD
lcd_pcb_h = 36;      // Altura da PCB do LCD

// --- DFPlayer Mini ---
dfplayer_x = 80;
dfplayer_y = 10;
dfplayer_w = 21;
dfplayer_d = 21;

// --- Botões (5 botões na tampa) ---
btn_diameter = 14;   // Diâmetro do furo para o botão
btn_spacing  = 28;   // Espaçamento entre centros dos botões
btn_y = 80;          // Posição Y dos botões (distância da borda frontal)
btn_start_x = 15;    // Posição X do primeiro botão

// --- Alto-falante ---
spk_diameter = 40;   // Diâmetro do alto-falante
spk_x = 135;         // Posição X do centro
spk_y = 55;          // Posição Y do centro

// --- Porta USB (abertura lateral na base) ---
usb_w = 14;          // Largura da abertura USB
usb_h = 12;          // Altura da abertura USB
usb_z = 5;           // Posição Z (altura desde o fundo interno)

// --- Porta do cartão SD do DFPlayer (abertura lateral) ---
sd_w = 14;
sd_h = 4;
sd_z = 8;

// --- Furos de montagem/parafusos (M3) ---
screw_r = 1.6;       // Raio do furo M3
screw_head_r = 3;    // Raio da cabeça do parafuso
pillar_r = 4;        // Raio do pilar de montagem
pillar_h = 5;        // Altura dos pilares internos

// --- Bateria 18650 (v2.0) ---
bat_length = 65;     // Comprimento da 18650
bat_diameter = 18;   // Diâmetro da 18650
bat_x = 55;          // Posição X do centro do berço (entre Arduino e DFPlayer)
bat_y = 55;          // Posição Y do centro do berço
bat_cradle_wall = 1.5; // Espessura da parede do berço

// --- Módulo TP4056 (v2.0) ---
tp4056_w = 25;       // Largura do módulo
tp4056_d = 19;       // Profundidade do módulo
tp4056_x = 5;        // Posição X (ao lado do Arduino)
tp4056_y = 62;       // Posição Y (acima do Arduino)
tp4056_usb_w = 10;   // Largura da abertura micro-USB
tp4056_usb_h = 4;    // Altura da abertura micro-USB
tp4056_usb_z = 5;    // Posição Z da abertura

// --- Potenciômetro de volume (v2.0) ---
pot_diameter = 7;    // Diâmetro do furo
pot_y = 70;          // Posição Y no lado direito
pot_z = 15;          // Posição Z (meia-altura)

// --- Chave slide on/off (v2.0) ---
sw_w = 13;           // Largura da abertura
sw_h = 5;            // Altura da abertura
sw_y = 85;           // Posição Y na lateral esquerda
sw_z = 20;           // Posição Z

// --- Motor de vibração coin (v2.0) ---
vib_diameter = 10;   // Diâmetro do motor coin
vib_thickness = 3;   // Espessura do motor
vib_x = 135;         // Posição X (perto do alto-falante)
vib_y = 35;          // Posição Y (abaixo do alto-falante, na base)

// --- Labels dos botões (v2.0 - profundidade aumentada) ---
label_depth = 0.8;   // Profundidade do label (era 0.4, agora 0.8)
btn_ring_width = 2;  // Largura do anel ao redor do botão
btn_ring_height = 0.5; // Altura do anel em relevo

// ===================== QUAL PEÇA RENDERIZAR =====================
// Descomente a peça que deseja visualizar/exportar:

render_base = true;
render_lid  = true;
// Para exportar separadamente, defina um como false

// Separação visual entre base e tampa
explode = 20; // Distância de separação (0 = montado)

// ===================== MÓDULOS =====================

// --- Retângulo arredondado 2D ---
module rounded_rect(w, d, r) {
    offset(r) square([w - 2*r, d - 2*r], center=false);
}

// --- Caixa arredondada 3D ---
module rounded_box(w, d, h, r) {
    translate([r, r, 0])
    linear_extrude(h)
    rounded_rect(w, d, r);
}

// --- Grade de ventilação para o alto-falante ---
module speaker_grille(diameter, hole_d=2.5, spacing=5) {
    r = diameter / 2;
    num = floor(diameter / spacing);
    for (ix = [-num/2 : num/2]) {
        for (iy = [-num/2 : num/2]) {
            px = ix * spacing;
            py = iy * spacing;
            if (sqrt(px*px + py*py) < r - 2) {
                translate([px, py, 0])
                cylinder(h=wall*3, d=hole_d, center=true, $fn=16);
            }
        }
    }
}

// --- Pilar de montagem ---
module mounting_pillar(h, screw_r, pillar_r) {
    difference() {
        cylinder(h=h, r=pillar_r, $fn=24);
        translate([0, 0, -0.1])
        cylinder(h=h+0.2, r=screw_r, $fn=16);
    }
}

// --- Encaixe snap-fit (aba na base) ---
module snap_tab(length=10, depth=1.5) {
    translate([0, 0, 0])
    cube([length, wall + depth, 2]);
}

// --- Berço para bateria 18650 (v2.0) ---
module battery_cradle() {
    cradle_h = bat_diameter / 2 + bat_cradle_wall; // Meia-lua + parede
    cradle_len = bat_length + 2;  // Folga de 1mm em cada ponta

    difference() {
        // Corpo externo do berço (bloco)
        translate([- cradle_len/2, - (bat_diameter/2 + bat_cradle_wall), 0])
        cube([cradle_len, bat_diameter + 2*bat_cradle_wall, cradle_h]);

        // Cavidade cilíndrica para a bateria
        translate([-cradle_len/2 - 0.5, 0, bat_diameter/2 + bat_cradle_wall])
        rotate([0, 90, 0])
        cylinder(h=cradle_len + 1, d=bat_diameter + 0.5, $fn=48);

        // Recorte superior para facilitar inserção/remoção (abertura de 120 graus)
        translate([-cradle_len/2 - 0.5, -(bat_diameter/2 + 2), cradle_h - 0.1])
        cube([cradle_len + 1, bat_diameter + 4, bat_diameter]);
    }

    // Abas de retenção nas pontas
    for (end = [-1, 1]) {
        translate([end * (cradle_len/2 - 1.5), 0, bat_diameter/2 + bat_cradle_wall])
        rotate([0, 90, 0])
        difference() {
            cylinder(h=1.5, d=bat_diameter + 2*bat_cradle_wall, $fn=48);
            translate([0, 0, -0.1])
            cylinder(h=1.7, d=bat_diameter + 0.5, $fn=48);
            // Cortar a parte de cima para manter a abertura
            translate([0, -(bat_diameter/2 + bat_cradle_wall + 1), 0])
            cube([bat_diameter + 2*bat_cradle_wall, bat_diameter + 2*bat_cradle_wall + 2, 2], center=false);
        }
    }
}

// --- Suporte para motor de vibração coin (v2.0) ---
module vibration_motor_mount() {
    mount_h = vib_thickness + 1;   // Altura do suporte
    outer_d = vib_diameter + 3;    // Diâmetro externo do anel

    difference() {
        // Anel externo
        cylinder(h=mount_h, d=outer_d, $fn=32);
        // Cavidade para o motor
        translate([0, 0, 1])
        cylinder(h=mount_h, d=vib_diameter + 0.5, $fn=32);
    }
    // Pequena aba de retenção (arco parcial)
    difference() {
        cylinder(h=mount_h + 0.5, d=outer_d, $fn=32);
        translate([0, 0, -0.1])
        cylinder(h=mount_h + 0.7, d=vib_diameter + 0.3, $fn=32);
        // Remover 270 graus, deixar só 90 graus de aba
        translate([-outer_d, -outer_d, -0.1])
        cube([outer_d, outer_d*2, mount_h + 1]);
        translate([0, 0, -0.1])
        cube([outer_d, outer_d, mount_h + 1]);
    }
}

// ===================== BASE =====================
module base() {
    total_w = case_width + 2*wall;
    total_d = case_depth + 2*wall;
    total_h = base_height + wall; // parede + fundo

    difference() {
        // Caixa externa
        rounded_box(total_w, total_d, total_h, corner_r);

        // Cavidade interna (sem o fundo)
        translate([wall, wall, wall])
        rounded_box(case_width, case_depth, base_height + 1, corner_r - wall/2);

        // --- Abertura USB do Arduino (lateral esquerda) ---
        translate([-0.1, wall + arduino_y + 15, wall + usb_z])
        cube([wall + 0.2, usb_w, usb_h]);

        // --- Abertura Jack de alimentação (lateral esquerda, abaixo do USB) ---
        translate([-0.1, wall + arduino_y + 35, wall + 3])
        cube([wall + 0.2, 12, 11]);

        // --- Abertura para cartão SD do DFPlayer (lateral direita) ---
        translate([total_w - wall - 0.1, wall + dfplayer_y + 2, wall + sd_z])
        cube([wall + 0.2, sd_w, sd_h]);

        // --- (v2.0) Furo para potenciômetro de volume (lateral direita) ---
        translate([total_w - wall - 0.1, wall + pot_y, wall + pot_z])
        rotate([0, 90, 0])
        cylinder(h=wall + 0.2, d=pot_diameter, $fn=32);

        // --- (v2.0) Abertura micro-USB do TP4056 (lateral esquerda) ---
        translate([-0.1, wall + tp4056_y + (tp4056_d - tp4056_usb_w)/2, wall + tp4056_usb_z])
        cube([wall + 0.2, tp4056_usb_w, tp4056_usb_h]);

        // --- (v2.0) Abertura chave slide on/off (lateral esquerda) ---
        translate([-0.1, wall + sw_y, wall + sw_z])
        cube([wall + 0.2, sw_w, sw_h]);
    }

    // --- Pilares de montagem nos cantos ---
    corner_inset = 8;
    pillar_positions = [
        [wall + corner_inset,                wall + corner_inset],
        [wall + case_width - corner_inset,   wall + corner_inset],
        [wall + corner_inset,                wall + case_depth - corner_inset],
        [wall + case_width - corner_inset,   wall + case_depth - corner_inset]
    ];

    for (pos = pillar_positions) {
        translate([pos[0], pos[1], wall])
        mounting_pillar(pillar_h, screw_r, pillar_r);
    }

    // --- Suportes para Arduino ---
    // Furos de montagem do Arduino Uno (posições relativas)
    arduino_holes = [
        [14, 2.5],
        [66.0, 7.6],
        [66.0, 35.6],
        [15.2, 50.8]
    ];
    for (hole = arduino_holes) {
        translate([wall + arduino_x + hole[0], wall + arduino_y + hole[1], wall])
        mounting_pillar(6, 1.4, 3); // M2.5 para Arduino
    }

    // --- (v2.0) Berço para bateria 18650 ---
    translate([wall + bat_x, wall + bat_y, wall])
    battery_cradle();

    // --- (v2.0) Suporte para motor de vibração ---
    translate([wall + vib_x, wall + vib_y, wall])
    vibration_motor_mount();

    // --- Borda de encaixe para a tampa ---
    translate([wall + tolerance, wall + tolerance, total_h - 0.1])
    difference() {
        rounded_box(case_width - 2*tolerance, case_depth - 2*tolerance, 2, corner_r - wall);
        translate([1.5, 1.5, -0.1])
        rounded_box(case_width - 2*tolerance - 3, case_depth - 2*tolerance - 3, 2.3, corner_r - wall - 1);
    }
}

// ===================== TAMPA =====================
module lid() {
    total_w = case_width + 2*wall;
    total_d = case_depth + 2*wall;
    total_h = lid_height + wall;

    difference() {
        union() {
            // Placa da tampa
            rounded_box(total_w, total_d, total_h, corner_r);
        }

        // Cavidade interna
        translate([wall, wall, -0.1])
        rounded_box(case_width, case_depth, lid_height + 0.1, corner_r - wall/2);

        // --- Janela do LCD ---
        translate([wall + lcd_x, wall + lcd_y, lid_height])
        cube([lcd_w, lcd_h, wall + 0.2]);

        // --- Rebaixo para a PCB do LCD (para que fique rente) ---
        translate([wall + lcd_x - 4, wall + lcd_y - 5, lid_height - 1.5])
        cube([lcd_pcb_w, lcd_pcb_h, 1.6]);

        // --- 5 Furos para botões ---
        for (i = [0:4]) {
            translate([wall + btn_start_x + i * btn_spacing, wall + btn_y, -0.1])
            cylinder(h=total_h + 0.2, d=btn_diameter, $fn=32);
        }

        // --- Grade do alto-falante ---
        translate([wall + spk_x, wall + spk_y, lid_height + wall/2])
        speaker_grille(spk_diameter);
    }

    // --- (v2.0) Labels em relevo nos botões - profundidade aumentada + anéis ---
    btn_labels = ["CAT<", "CAT>", "PAL<", "PAL>", "VOZ"];
    btn_colors_comment = ["Verm", "Amar", "Verde", "Azul", "Preto"];

    for (i = [0:4]) {
        bx = wall + btn_start_x + i * btn_spacing;
        by = wall + btn_y;

        // --- Anel em relevo ao redor do botão (v2.0: 2mm largura, 0.5mm altura) ---
        translate([bx, by, total_h])
        difference() {
            cylinder(h=btn_ring_height, d=btn_diameter + 2*btn_ring_width + 2, $fn=32);
            translate([0, 0, -0.1])
            cylinder(h=btn_ring_height + 0.2, d=btn_diameter + 2, $fn=32);
        }

        // --- Indicador de profundidade (label gravado) ---
        translate([bx, by, total_h - 0.1])
        difference() {
            cylinder(h=label_depth + 0.1, d=btn_diameter + 2*btn_ring_width + 2 + 4, $fn=32);
            translate([0, 0, -0.1])
            cylinder(h=label_depth + 0.3, d=btn_diameter + 2*btn_ring_width + 2 + 1, $fn=32);
        }
    }

    // --- Suporte interno para o LCD ---
    lcd_support_h = lid_height - 2;
    // Cantoneiras
    translate([wall + lcd_x - 5, wall + lcd_y - 6, 0]) {
        cube([2, lcd_pcb_h + 2, lcd_support_h]);
        translate([lcd_pcb_w + 8, 0, 0])
        cube([2, lcd_pcb_h + 2, lcd_support_h]);
    }
}

// ===================== RENDERIZAÇÃO =====================

$fn = 48; // Resolução das curvas

if (render_base) {
    color("SteelBlue", 0.9)
    base();
}

if (render_lid) {
    total_h_base = base_height + wall;
    color("LightSkyBlue", 0.85)
    translate([0, 0, total_h_base + explode])
    // Espelhar a tampa (ela encaixa virada para baixo)
    mirror([0, 0, 1])
    translate([0, 0, -(lid_height + wall)])
    lid();
}
