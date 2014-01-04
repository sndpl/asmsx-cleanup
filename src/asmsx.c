#include "core.c"
#include "lex.c"

int main(int argc, char *argv[])
{
    int i;
    printf("--------------------------------------------------------------------------------\n");
    printf(" asmsx v.%s. MSX cross-assembler. Eduardo A. Robsy Petrus [%s]\n", VERSION, __DATE__);
    printf("--------------------------------------------------------------------------------\n");
    if (2 != argc)
    {
        printf("Syntax: asmsx [file.asm]\n");
        exit(0);
    }
    clock();
    initialize_system();
    assembler = (unsigned char*)malloc(0x100);
    source = (unsigned char*)malloc(0x100);
    original = (unsigned char*)malloc(0x100);
    binary = (char*)malloc(0x100);
    symbols = (char*)malloc(0x100);
    outputfname = (char*)malloc(0x100);
    filename = (char*)malloc(0x100);
    strcpy(filename, argv[1]);
    strcpy(assembler, filename);
    for (i = strlen(filename) - 1; (filename[i] != '.') && i; i--);
    if (i) filename[i]=0; else strcat(assembler, ".asm");
    preprocessor1(assembler);
    preprocessor3();
    sprintf(original, "~tmppre.%i", preprocessor2());
    printf("Assembling source file %s\n", assembler);
    conditional[0] = 1;
    foriginal = fopen(original, "r");
    yyin = foriginal;
    yyparse();
    remove("~tmppre.?");
    return 0;
}