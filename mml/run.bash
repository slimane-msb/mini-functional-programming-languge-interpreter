# check if there is exactly one argument 
if [ $# -ne 1 ]; then
    echo "Usage: $0 <file>"
    exit 1
fi

#print the file name
echo "File: $1"

# mettre a jour ocamlBuild
rm mmli.native && rm mmlcat.native

#run command ocamlbuild to compile the file

ocamlbuild mmlcat.native && ./mmlcat.native tests/$1.mml; ocamlbuild mmli.native && ./mmli.native tests/$1.mml
