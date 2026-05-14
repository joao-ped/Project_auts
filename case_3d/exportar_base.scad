// Arquivo auxiliar para exportar APENAS a base como STL
// Abra este arquivo no OpenSCAD > F6 (Render) > Export as STL
//
// A base é exportada na orientação correta (fundo na mesa).

include <case_voz_autista.scad>

// No OpenSCAD, a última atribuição no escopo raiz prevalece.
render_base = true;
render_lid  = false;
explode = 0;
