#!/usr/bin/env python3
import glob
import networkx as nx

for filename in glob.iglob('../**/*.links', recursive=True):
    #print( filename )
    # TODO: translate filename into file object, construct nodes and edges and their data from .links files
