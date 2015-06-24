""" This script generates docs in markdown format for randomkit.* """

import numpy
import re

def getDocStrings(funcNames, exceptions):

    for funcName in funcNames:
        func = getattr(numpy.random, funcName, None)
        if not func:
            print("Could not find numpy docstring for %s" % (funcName,))
            continue

        if funcName[0] == '_':
            continue
        if funcName in exceptions:
            continue

        docLines = func.__doc__.strip().split("\n")
        funcSig = re.sub("=[^,)]+", "", docLines[0])
        funcSig = re.sub(",?\s*size", "", funcSig)
        funcSig = re.sub("\(", "([output], ", funcSig)
        funcSig = "randomkit." + funcSig
        doc = "\n".join(x.strip() for x in docLines[1:])
        doc = re.sub(">>>", "     $", doc)
        doc = re.sub("\.\.\. ", "     ", doc)
        doc = re.sub("#", "", doc)
        doc = re.sub("\]_", "]", doc)
        doc = re.sub('.+ : .+',"* \g<0>", doc)
        doc = re.sub('\.\. \[(\d+?)\]', "\g<1>.", doc)
        doc = re.sub('(.+?)\n-+', "####\g<1>", doc)
        doc = re.sub('`(.+)\n<(.+)>`_', "1. \g<1>, \g<2>", doc)
        doc = re.sub(':math:`(.+?)`', "\\\\\(\g<1>\\\\\)", doc)
        doc = re.sub('\.\. math::(.+?)\n\n', "$$\g<1>$$\n\n", doc, flags=re.S)
        doc = re.sub('     \$ (.+)\n([^ ])', '     $ \g<1>\n\n\g<2>', doc)
        doc = re.sub('^([^ \n].+?)\n     \$', '\g<1>\n\n     $', doc, flags=re.M)
        doc += "\n"

        yield funcName, funcSig, doc

def writeMDdoc(funcNames, funcInfo, introFile, docFile):
    with open(introFile, 'r') as f:
        introduction = f.read()
    with open(docFile, 'w') as f:
        f.write(introduction+"\n")
        f.write("#List of distributions\n")
        for name, sig, doc in funcInfo:
            f.write("##"+name+"\n")
            f.write(sig+"\n")
            f.write(doc+"\n")
            print("Generated doc for " + name)

if __name__ == "__main__":
    introFile = "doc/intro.md"
    docFile = "README.md"
    funcNames = dir(numpy.random)
    excluded = ['RandomState', 'seed', 'set_state', 'get_state', 'choice', 'rand', 
        'randn', 'Tester', 'operator','warnings', 'info','test','bench', 'permutation',
        'np', 'absolute_import', 'division', 'mtrand', 'print_function',
        'random_integers', 'ranf', 'sample', 'shuffle']
    funcInfo = list(getDocStrings(funcNames, excluded))

    writeMDdoc(funcNames, funcInfo, introFile, docFile)