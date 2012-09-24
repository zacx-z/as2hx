include "haxeAddons.grm"

rule main
    replace $ [program]
        C [program]
    construct newC [program]
        C [replaceId 'Number 'Float] [replaceId 'void 'Void] [replaceId 'int 'Int] [replaceId 'uint 'UInt] [replaceId 'Function 'Dynamic] [replaceId 'Class 'Dynamic] [replaceId 'Boolean 'Bool] [replaceId 'Object 'Dynamic]
        [replaceConst] [replaceProtected] [replaceVector] [fixArray]
        [replacePackageDefinition] [replacePackageDefinition2] [removeClassModifier] [removeOverriderModifier] [replaceForLoop1]
        [classConstructorReplace] [castFix] [castAsFix] [reflectNewInstanceFix] [reflectNewInstanceFixWithoutArgs] [addConstructorSuper] [moveMemberVarInit] [isInstanceFix] [newFix]
        [replaceSetter] [replaceGetter] [replaceEmbed]
        [generateClassDefFile] [generateTypeUsedFile] [generateImportStarLines]
    where not
        newC [= C]
    by
        newC
end rule

rule replaceId T [id] N [id]
    replace [id]
        T
    by
        N
end rule

rule replaceConst
    replace [varConst]
        'const
    by
        'var
end rule

rule replaceProtected
    replace [modifier]
        'protected
    by
        'private
end rule

rule classConstructorReplace
    replace $ [classDefinition]
        C [classDefinition]
    deconstruct * [classHeader] C
        _ [modifier?] CK [classInterface] Name [id] D [classDerivation?] I [interfaceImplementation?]
    by
        C [constructorReplace Name]
end rule

rule constructorReplace Name [id]
    replace $ [memberFuncHeader]
        Modifiers [modifiers?] 'function Name (Formals[formalList])
    by
        Modifiers 'function 'new (Formals)
end rule

rule castFix
    replace [funcCall]
        ClassName [id] (Arg [expression])
    construct first [id]
        ClassName [: 1 1]
    where all
        ClassName [>= "A"] [<= "Z"]
    by
        cast (Arg, ClassName)
end rule

rule castAsFix
    replace [expression]
        E [expression] 'as Class [id]
    by
        cast(E, Class)
end rule

rule reflectNewInstanceFix
    replace [primary]
        'new ClassObject [id] (Args [expression,])
    construct first [id]
        ClassObject [: 1 1]
    where all
        ClassObject [>= "a"] [<= "z"]
    by
        Type'.createInstance(classObject, '[Args'])
end rule

rule reflectNewInstanceFixWithoutArgs
    replace [primary]
        'new ClassObject [id]
    construct first [id]
        ClassObject [: 1 1]
    where all
        ClassObject [>= "a"] [<= "z"]
    by
        Type'.createInstance(ClassObject, '['])
end rule

rule addConstructorSuper
    replace [memberFuncDefinition]
        M [modifiers?] 'function 'new (F [formalList]) Body [memberFuncBody]
    deconstruct not * [statement] Body
        super Args [arguments] ';
    deconstruct Body
        '{
            Stats [statement*]
        '}
    by
        M 'function 'new (F) '{ 
            super() ';
            Stats 
        '}
end rule

rule moveMemberVarInit
    replace [classBody]
        Body [classBody]
    deconstruct * [memberVarDefinition] Body
        M [modifiers?] 'var Name [id] T [typeDeclaration] Eval [evaluation] ';
    by
        Body [removeInit Name] [addInit Name Eval]
end rule

function removeInit Name [id]
    replace * [memberVarDefinition]
        M [modifiers?] 'var Name T [typeDeclaration] Eval [evaluation] ';
    by
        M 'var Name T ';
end function

function addInit Name [id] Eval [evaluation]
    replace * [memberFuncDefinition]
        M [modifiers?] 'function 'new (F [formalList]) '{
            Stats [statement*]
        '}
    deconstruct Eval
        '= E [expression]
    by
        M 'function 'new (F) '{
            Name '= E ';
            Stats
        '}
end function

rule isInstanceFix
    replace [expression]
        E [expression] 'is C [id]
    by
        Std '. is(E, C)
end rule

rule newFix
    replace [newInstance]
        'new C [type]
    by
        'new C ()
end rule

define varEntry
    [id] ': [type]
end define

rule generateClassDefFile
    replace $ [memberVarDefinition]
        M [memberVarDefinition]
    deconstruct M
        MD [modifiers?] 'var Name [id] ': T [type]';
    construct V [varEntry]
        Name ': T 
    construct _ [varEntry]
        V [fput "class.def"]
    by
        M
end rule

rule generateTypeUsedFile
    replace $ [type]
        T [type]
    by
        T [fput "types.used"]
end rule

rule generateImportStarLines
    replace $ [importDeclaration]
        'import A [id] B [dotLibField*] C [dotStar] ';
    construct I [importDeclaration]
        'import A B C ';
    by
        I [fput "import.stars"]
end rule

rule replaceSetter
    replace [memberFuncHeader]
        O [overrideModifier?] M [modifiers?] 'function 'set Name [id] (F[formalList]) T [typeDeclaration?]
    construct newName [id]
        Name [+ "Set"]
    by
        '@:setter(Name) O M 'function newName (F) T
end rule

rule replaceGetter
    replace [memberFuncHeader]
        O [overrideModifier?] M [modifiers?] 'function 'get Name [id] (F[formalList]) T [typeDeclaration?]
    construct newName [id]
        Name [+ "Get"]
    by
        '@:getter(Name) O M 'function newName (F) T
end rule

rule replaceEmbed
    replace [classDefinition*]
        Cs [classDefinition*]
    deconstruct * [classDefinition] Cs
        C [classDefinition]
    deconstruct * [memberVarDefinition] C
        '[Embed(Fields [metaField,])'] M [modifiers?] V [varConst] Name [id] T [typeDeclaration?] ';
    deconstruct * [metaField] Fields
        source '= Src [stringlit]
    construct E [id]
        'E
    construct newName [id]
        E [+ Name] [!]
    by
        C [genNewEmb newName Src] [genNewEmbBitmap newName Src] [genNewEmbSound newName Src]
        Cs [doReplaceEmbed Name newName C]
end rule

rule doReplaceEmbed Name [id] newName [id] C [classDefinition]
    replace $ [classDefinition] 
        C
    by
        C [removeMemberVar Name] [replaceId Name newName]
end rule

rule genNewEmb Name [id] Src [stringlit]
    replace $ [classDefinition]
        _ [classDefinition]
    by
        '@:file(Src) 'private 'class Name 'extends flash'.utils'.ByteArray '{'}
end rule

rule genNewEmbBitmap Name [id] Src [stringlit]
    replace $ [classDefinition]
        _ [classDefinition]
    construct L [number]
        _ [# Src]
    construct I [number]
        L [- 3]
    construct S [stringlit]
        Src [: I L]
    where
        S [= ".png"] [= ".jpg"] [= "jpeg"]
    by
        '@:bitmap(Src) 'private 'class Name 'extends flash'.display'.BitmapData '{'}
end rule

rule genNewEmbSound Name [id] Src [stringlit]
    replace $ [classDefinition]
        _ [classDefinition]
    construct L [number]
        _ [# Src]
    construct I [number]
        L [- 3]
    construct S [stringlit]
        Src [: I L]
    where
        S [= ".wav"] [= ".mp3"]
    by
        '@:bitmap(Src) 'private 'class Name 'extends flash'.media'.Sound '{'}
end rule

rule removeMemberVar Name [id]
    replace [memberDefinition*]
        MD [metadata] M [modifiers?] V [varConst] Name T [typeDeclaration?] ';
        Defs [memberDefinition*]
    by
        Defs
end rule
        
rule replacePackageDefinition
    replace $ [program]
        package P [id] '{
            C [classDefinitionWithImport]
        '}
    by
        package P ';
        C
end rule

rule replacePackageDefinition2
    replace $ [program]
        package '{
            C [classDefinitionWithImport]
        '}
    by
        C
end rule

rule removeClassModifier
    replace [classHeader]
        'public C [classInterface] Name [id] D [classDerivation?] I [interfaceImplementation?]
    by
        C Name D I
end rule

rule removeOverriderModifier
    replace [memberFuncHeader]
        MD [metadata?] O [overrideModifier] M [modifiers] 'function GS [getterSetter?] Name [id] (F [formalList]) T [typeDeclaration?]
    by
        MD O 'function GS Name (F) T
end rule

rule replaceForLoop1
    replace [forStatement]
        'for (X [id] '= E1 [expression]'; X '< E2 [arithExp] '; X '++)
            S [statement]
    by
        'for (X 'in E1 '... E2)
            S
end rule

rule replaceVector
    replace [type]
        'Vector '. '< T [type] '>
    by
        Array '< T '>
end rule

rule fixArray
    replace [type]
        'Array
    by
        Array '< Dynamic '>
end rule
