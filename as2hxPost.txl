include "as.grm"
include "haxeAddons.grm"

rule main
    replace $ [classDefinitionWithImport]
        C [classDefinitionWithImport]
    by
        C [removeImportStar] [addGeneratedImport]
end rule

rule removeImportStar
    replace [importDeclaration*]
        'import A [id] B [dotLibField*] C [dotStar]';
        Rest [importDeclaration*]
    by
        Rest [removeImportStar]
end rule

rule addGeneratedImport
    replace [classDefinitionWithImport]
        I [importDeclaration*]
        Ms [metadata*]
        Cs [classDefinition*]
    construct R [importDeclaration*]
        I [fget "import.gen"]
    deconstruct R
        'import A [id] B [dotLibField*] '; N [NL]
    by
        'import A B';
        I
        Ms
        Cs
end rule
