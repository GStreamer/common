# -*- Mode: Python -*-
# vi:si:et:sw=4:sts=4:ts=4

"""
use the output from gst-xmlinspect.py to mangle tmpl/*.sgml and
insert/overwrite Short Description and Long Description
"""

import glob
import re
import sys
import os
import gst

class Tmpl:
    def __init__(self, filename):
        self.filename = filename
        self._sectionids = []
        self._sections = {}

    def read(self):
        """
        Read and parse the sections from the given file.
        """
        lines = open(self.filename).readlines()
        matcher = re.compile("<!-- ##### SECTION (\S+) ##### -->\n")
        id = None

        for line in lines:
            match = matcher.search(line)
            if match:
                id = match.expand("\\1")
                self._sectionids.append(id)
                self._sections[id] = []
            else:
                if not id:
                    sys.stderr.write(
                        "WARNING: line before a SECTION header: %s" % line)
                else:
                    self._sections[id].append(line)

    def set_section(self, id, content):
        """
        Replace the given section id with the given content.
        """
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
        target = self.filename + ".mangle.bak"
        os.rename(self.filename, target)
        handle = open(self.filename, "w")
        handle.write(self.output())
        handle.close()

        
def main():
    if len(sys.argv) > 1 and sys.argv[1]:
        os.chdir(sys.argv[1])

    elements = {}
    all = gst.registry_pool_plugin_list()
    for plugin in all:
        for feature in plugin.get_feature_list():
            if isinstance(feature, gst.ElementFactory):
                elements[feature.get_name()] = feature
                
    for file in glob.glob("element-*.sgml"):
        base = os.path.basename(file)
        element = base[len("element-"):-len(".sgml")]
        tmpl = Tmpl(file)
        tmpl.read()
        if element in elements.keys():
            feature = elements[element]
            description = feature.get_description()
            tmpl.set_section("Short_Description", "%s\n\n" % description)
        tmpl.set_section("Long_Description",
            '<include xmlns="http://www.w3.org/2003/XInclude" href="element-' +
            element + '-details.xml" />\n<para>\n\n</para>\n')
        tmpl.write()

main()
