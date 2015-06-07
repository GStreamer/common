# -*- Mode: Python -*-
# vi:si:et:sw=4:sts=4:ts=4

"""
use the files from inspect/*.xml to create mininal tmpl/*.sgml files containing
'Short Description' and 'Long Description' to inject element details into the
docbook files produced by gtkdoc-mkdb
"""

from __future__ import print_function, unicode_literals

import glob
import sys
import os

class Tmpl:
    def __init__(self, filename):
        self.filename = filename
        self._sectionids = []
        self._sections = {}

    def set_section(self, id, content):
        """
        Replace the given section id with the given content.
        """
        if not id in self._sectionids:
            self._sectionids.append(id)
        self._sections[id] = content

    def output(self):
        """
        Return the output of the current template in the tmpl/*.sgml format.
        """
        lines = []
        for id in self._sectionids:
            lines.append("<!-- ##### SECTION %s ##### -->\n" % id)
            for line in self._sections[id]:
                lines.append(line)

        return "".join(lines)

    def write(self):
        """
        Write out the template file again, backing up the previous one.
        """
        handle = open(self.filename, "w")
        handle.write(self.output())
        handle.close()

import xml.dom.minidom

def get_elements(file):
    elements = {}
    doc = xml.dom.minidom.parse(file)

    elem = None
    for e in doc.childNodes:
        if e.nodeType == e.ELEMENT_NODE and e.localName == 'plugin':
            elem = e
            break
    if elem == None:
        return None

    elem2 = None
    for e in elem.childNodes:
        if e.nodeType == e.ELEMENT_NODE and e.localName == 'elements':
            elem2 = e
            break
    if elem2 == None:
        return None

    elem = elem2

    for e in elem.childNodes:
        if e.nodeType == e.ELEMENT_NODE and e.localName == 'element':
            name = None
            description = None

            for e2 in e.childNodes:
                if e2.nodeType == e2.ELEMENT_NODE and e2.localName == 'name':
                    name = e2.childNodes[0].nodeValue.encode("UTF-8")
                elif e2.nodeType == e2.ELEMENT_NODE and e2.localName == 'description':
                    if e2.childNodes:
                      description = e2.childNodes[0].nodeValue.encode("UTF-8")
                    else:
                      description = 'No description'

            if name != None and description != None:
                elements[name] = {'description': description}

    return elements

def main():
    if not len(sys.argv) == 3:
        sys.stderr.write('Please specify the inspect/ dir and the tmpl/ dir')
        sys.exit(1)

    inspectdir = sys.argv[1]
    tmpldir = sys.argv[2]

    if not os.path.exists (tmpldir):
        os.mkdir(tmpldir)

    # parse all .xml files; build map of element name -> short desc
    #for file in glob.glob("inspect/plugin-*.xml"):
    elements = {}
    for file in glob.glob("%s/plugin-*.xml" % inspectdir):
        elements.update(get_elements(file))

    for element in elements.keys():
        file = "%s/element-%s.sgml" % (tmpldir, element)
        tmpl = Tmpl(file)

        description = elements[element]['description']
        tmpl.set_section("Short_Description", "%s\n" % description)

        # add include for details
        line = '<include xmlns="http://www.w3.org/2003/XInclude" href="' + \
            'element-' + element + '-details.xml">' + \
            '<fallback xmlns="http://www.w3.org/2003/XInclude" />' + \
            '</include>\n'
        tmpl.set_section("Long_Description", line)
        tmpl.write()

main()
