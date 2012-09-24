About
=
A tool used to translate AS3 code into Haxe code, written in TXL (http://www.txl.ca) and Haskell.  Developed by Ladace (http://godhatesnerds.net)

This is NOT a complete converter, but it can reduce much work you have to do when translating AS3 code into Haxe.

To convert AS3 into Haxe completely, the next phase is adding semantic analysis of AS, which is complicated and difficult.

#Features
<ul>
<li>Transformation based on grammar has been basically completed. </li>
<li>Expand the "import xxx.*;" declaration automatically.  However, some import may be missed, and should be added manually.</li>
</ul>

#Note

<ul>
<li>The input AS3 code is required to have ';' following each statement.  If not, the transformation will fail. </li>
<li>The <b>Function</b> and <b>Class</b> type are translated into <b>Dynamic</b> in Haxe.</li>
</ul>

#Build
<ul>
<li>Install TXL (http://www.txl.ca) and Haskell(http://www.haskell.org).</li>
<li>Run the build.sh or build.bat.</li>
</ul>

Windows users can use the binary version "as2hx.exe" directly.

#Usage
as2hx [file|directory]

The output code will be placed in the folder "hxOutput/".
If a directory is specified, all AS files under the directory will be processed recursively.

#P.S.
You can find previous version here (https://github.com/ladace/NerdLab/tree/master/libraries/as2hx).
