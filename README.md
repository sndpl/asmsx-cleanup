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

After a while my progress grinded to a halt. Making significant changes to code
is very risky without a proper test harness, and building test units is very
difficult due to extremely convoluted and interdependent nature of the code.

I decided to put asmsx-cleanup project on pause and instead write a new Z80
cross-assembler for MSX from scratch. I'm using Python and PLY. saspy is now on
GitHub: <https://github.com/oboroc/saspy/>.

Adrian Oboroc
May 2, 2014
