FROM centos:7

RUN yum update -y

# python3 is not included in the following, nor is pip
RUN yum groupinstall "Development Tools" -y

# doxygen is for C++
RUN yum install -y graphviz doxygen

#RUN yum install -y python3
RUN yum install -y python3-pip
#RUN yum install -y python3-devel
#RUN yum install -y python3-setuptools

# sphinx is documentation for Python
# https://breathe.readthedocs.io/en/latest/
# Breathe provides a bridge between the Sphinx and Doxygen documentation systems.
RUN pip3 install sphinx sphinx_rtd_theme breathe

RUN mkdir /opt/proj/
RUN mkdir /opt/proj/source/
RUN mkdir /opt/proj/doc/
RUN mkdir /opt/proj/doc/doxygen
RUN mkdir /opt/proj/doc/sphinx

WORKDIR /opt/proj/

COPY source_code/CatCutifier.cpp \
     source_code/CatCutifier.hpp \
     source_code/simple_example.cpp \
     source_code/simple_example.py \
     /opt/proj/source/


# https://devblogs.microsoft.com/cppblog/clear-functional-c-documentation-with-sphinx-breathe-doxygen-cmake/

WORKDIR /opt/proj/doc/doxygen/
# generate a template configuration file
RUN doxygen -g Doxyfile.config
# from https://gist.github.com/slog2/cc853c34ded1dc1622165e95d95acd1c
RUN sed -i 's/^HAVE_DOT.*/HAVE_DOT = YES/'             Doxyfile.config && \
    sed -i 's/^SOURCE_BROWSER.*/SOURCE_BROWSER = YES/' Doxyfile.config && \
    sed -i 's/^UML_LOOK.*/UML_LOOK = YES/'             Doxyfile.config && \
    sed -i 's/^CALL_GRAPH.*/CALL_GRAPH = YES/'         Doxyfile.config && \
    sed -i 's/^CALLER_GRAPH.*/CALLER_GRAPH = YES/'     Doxyfile.config && \
    sed -i 's/^RECURSIVE.*/RECURSIVE = YES/'           Doxyfile.config && \
    sed -i 's/^INPUT .*/INPUT = ..\/..\/source/'         Doxyfile.config

# as per https://breathe.readthedocs.io/en/latest/
RUN sed -i 's/^GENERATE_XML.*/GENERATE_XML = YES/' Doxyfile.config

RUN doxygen Doxyfile.config

RUN cd /opt/proj/doc/ && \
    sphinx-quickstart --sep --makefile sphinx \
    --project "My Proj" \
    --author "Ben" \
    --release "latest" \
    --language "en"

WORKDIR /opt/proj/doc/sphinx/source

RUN sed -i 's/# import os.*/import os/' conf.py 
RUN sed -i 's/# import sys.*/import sys/' conf.py
RUN sed -i 's/# sys\.path\.insert.*/sys.path.insert(0, os.path.abspath("..\/..\/..\/source\/"))/' conf.py

# https://breathe.readthedocs.io/en/latest/
RUN head -n 12 index.rst                  >  index_new.rst && \
    # python
    echo ".. automodule:: my_project.simple_example" >> index_new.rst && \
    echo "   :members:"                   >> index_new.rst && \
    # C++
    echo ".. doxygenclass:: cat"  >> index_new.rst && \
    echo "   :members:"                   >> index_new.rst && \
    echo ".. doxygenclass:: Nutshell"     >> index_new.rst && \
    echo "   :project: nutshell"          >> index_new.rst && \
    echo "   :members:"                   >> index_new.rst && \
    tail -n 8 index.rst                   >> index_new.rst && \
    mv index.rst index_OLD.rst && \
    mv index_new.rst index.rst

# by default Sphinx only understands docstrings written in traditional reStructuredText.
# The Napoleon extension enables Sphinx to understand docstrings written in two other popular formats: NumPy and Google.
RUN sed -i 's/^extensions = .*/extensions = \[ "breathe", "sphinx.ext.napoleon", "sphinx.ext.autodoc", "sphinx.ext.coverage"/' conf.py

RUN sed -i '26 a breathe_projects = { "nutshell":"../../doxygen/xml/", "CatCutifier":"../../doxygen/xml/" }' conf.py

RUN cd /opt/proj/doc/sphinx && \
    make html

WORKDIR /opt/proj/

# output is in
# /opt/proj/doc/sphinx/build/html/index.html
