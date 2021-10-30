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

RUN mkdir /opt/source/

COPY source_code/CatCutifier.cpp \
     source_code/CatCutifier.hpp \
     source_code/simple_example.cpp \
     source_code/simple_example.py \
     /opt/source/


# https://devblogs.microsoft.com/cppblog/clear-functional-c-documentation-with-sphinx-breathe-doxygen-cmake/

# generate a template configuration file
RUN cd /opt && \
    doxygen -g Doxyfile.config


RUN cd /opt && \
    sphinx-quickstart --sep --makefile docs/Sphinx \
    --project "My Proj" \
    --author "Ben" \
    --release "latest" \
    --language "en"
