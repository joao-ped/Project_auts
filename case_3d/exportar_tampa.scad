// Arquivo auxiliar para exportar APENAS a tampa como STL
// Abra este arquivo no OpenSCAD > F6 (Render) > Export as STL
//
// A tampa é exportada INVERTIDA (botões para cima) para que
// a superfície plana fique na mesa da impressora.
// Isso elimina a necessidade de suportes nos furos dos botões,
// janela do LCD e grade do alto-falante.

include <case_voz_autista.scad>

// No OpenSCAD, a última atribuição no escopo raiz prevalece.
// Estas linhas desativam a renderização automática do include.
render_base = false;
render_lid  = false;
explode = 0;

// Renderiza a tampa invertida (flip em Z)
translate([0, 0, lid_height + wall])
mirror([0, 0, 1])
lid();
