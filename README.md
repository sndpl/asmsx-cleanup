![asmsx](doc/asmsx.png)

asmsx-cleanup
=============

asmsx is a Z80 cross-assembler for MSX family of 8-bit computers, written
originally by Eduardo Robsy Petrus. Eduardo worked on asmsx for a decade before
he decided to discontinue any further efforts and sold full rights to product
on eBay. cjv99 purchased the rights and released the source code under GPLv3
license here: <https://code.google.com/p/asmsx-license-gpl/>.

I started tinkering with asmsx source in late 2013. First I translated Spanish
to English, both the source code and documentation. Next I've started
reformatting and bug fixing the code with the help of warnings from a variety of
C compilers (GCC, Visual C++, Digital Mars and Watcom C/C++) and CppCheck
static code analyzer.

In May 2014 my progress grinded to a halt. Making significant changes to code
was very risky without a proper test harness. Building test units is difficult
due to extremely convoluted and interdependent nature of code.

I started tinkering with this project again in July 2015. Right now I'm
building a Visual Studio 6 project that uses flex/bison from git Windows
client.
