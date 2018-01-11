% Document class for research/technical/research review reports
% at CTU FIT (http://fit.cvut.cz)
% 2015/04/12 Created by Ondrej Guth <ondrej.guth@fit.cvut.cz>
% 

\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{FITreport}[2015/04/12 CTU FIT standard class for research/technical reports]

\DeclareOption{czech}{
	\AtBeginDocument{\selectlanguage{czech}}
	\PassOptionsToPackage{english,main=czech}{babel}
	\def\@lang{1}
}
\DeclareOption{english}{
	\AtBeginDocument{\selectlanguage{english}}
	\PassOptionsToPackage{english}{babel}
	\def\@lang{0}
}
\DeclareOption{research}{\def\@reporttype{1}}
\DeclareOption{review}{\def\@reporttype{2}}
\DeclareOption{technical}{\def\@reporttype{3}}

\DeclareOption{10pt}{\PassOptionsToClass{\CurrentOption}{memoir}}
\DeclareOption{11pt}{\PassOptionsToClass{\CurrentOption}{memoir}}
\DeclareOption{12pt}{\PassOptionsToClass{\CurrentOption}{memoir}}

\ExecuteOptions{11pt}

\ProcessOptions

\LoadClass[a4paper,oneside,article,openany]{memoir}[2013/05/30]

\RequirePackage{babel}[2014/09/25]
\RequirePackage{graphicx}


\counterwithout{section}{chapter}
\setsecnumdepth{subsubsection}

\DeclareRobustCommand{\reportNumber}[1]{\def\the@ReportNumber{#1}}
\DeclareRobustCommand{\reportYear}[1]{\def\the@ReportYear{#1}}
\DeclareRobustCommand{\published}[1]{\def\the@published{#1}}
\DeclareRobustCommand{\affil}[1]{\if\@inmaketitle1 \\
#1\\
\fi}

\DeclareRobustCommand{\theFIT}{\the@FITname\\\theFITaddress}

\date{}
\DeclareRobustCommand{\date}{}

% % % % % internal definitions

\def\@inmaketitle{0}

\DeclareRobustCommand{\maketitlehookb}{\def\@inmaketitle{1}}
\DeclareRobustCommand{\maketitlehookc}{\def\@inmaketitle{0}}

\DeclareRobustCommand{\the@reportLabel}{%
\if\@lang1{%
\if\@reporttype1{%
V{\' y}zkumn{\' a}
}\else\if\@reporttype2{%
Souhrnn{\' a} v{\' y}zkumn{\' a}
}\else{%
Technick{\' a}
}\fi\fi zpr{\' a}va}\else{%
\if\@reporttype1{%
Research
}\else\if\@reporttype2{%
Research review
}\else{%
Technical
}\fi\fi Report}\fi}

\DeclareRobustCommand{\the@ReportID}{\if\@reporttype1{R}\else\if\@reporttype2{RR}\else{T}\fi\fi{}R-FIT-\the@ReportYear{}-\the@ReportNumber{}
}

\DeclareRobustCommand{\the@FITname}{\if\@lang1{Fakulta informa{\v c}n{\' i}ch technologi{\' i}}\else{Faculty of Information Technology}\fi}
\DeclareRobustCommand{\the@CVUTname}{\if\@lang1{{\v C}esk{\' e} vysok{\' e} u{\v c}en{\' i} technick{\' e} v~Praze}\else{Czech Technical University in Prague}\fi}
\DeclareRobustCommand{\the@FITaddressStreet}{Th{\' a}kurova~9}
\DeclareRobustCommand{\the@FITaddressCity}{Praha~6}
\DeclareRobustCommand{\the@FITaddressPC}{160~00}
\DeclareRobustCommand{\the@FITaddressCountry}{\if\@lang1{{\v C}esk{\'a} republika}\else{Czech Republic}\fi}
\DeclareRobustCommand{\theFITaddress}{\the@FITaddressStreet\\\the@FITaddressPC{}~\the@FITaddressCity\\\the@FITaddressCountry}


\newif\if@abstractdefined
\DeclareRobustCommand{\abstractL}[1]{
	\def\@theabstractL{#1}
	\@abstractdefinedtrue
}

\newif\if@abstractendefined
\DeclareRobustCommand{\abstractEN}[1]{
	\def\@theabstracten{#1}
	\@abstractendefinedtrue
}

\newif\if@keywordsdefined
\DeclareRobustCommand{\keywordsL}[1]{
	\def\@thekeywordsL{#1}
	\@keywordsdefinedtrue
}

\newif\if@keywordsendefined
\DeclareRobustCommand{\keywordsEN}[1]{
	\def\@thekeywordsen{#1}
	\@keywordsendefinedtrue
}

% \setlength{\absleftindent}{-20pt}
% \setlength{\absrightindent}{-20pt}
\renewcommand{\absnamepos}{flushleft}
\renewcommand{\abstractnamefont}{\normalfont\bfseries}
\renewcommand{\abstracttextfont}{\normalfont}
% \setlength{\absparindent}{0pt}
% \setlength{\absparsep}{-1em}
% \setlength{\abstitleskip}{-1em}

\AtBeginDocument{
	\begin{titlingpage}
		\centering
		\sffamily
		
	    \textbf{\fontsize{21}{21}\selectfont \the@FITname}
	    
% 	    \vspace{.1\textheight}
		\vfill
	    
	    \framebox[.99\textwidth]{
	    
			\begin{minipage}{.9\textwidth}
			\centering
			
			\bigskip

			\textbf{\fontsize{18}{18}\selectfont \thetitle}
			
			\bigskip
			
			{\fontsize{18}{18}\selectfont \theauthor}
			
			\medskip
			
			{\fontsize{12}{12}\selectfont\the@reportLabel{} \the@ReportID}
			
			\medskip
			
			\end{minipage}

	    }
	    
	    \vfill
	    
	    \includegraphics[width=.8\textwidth]{cvut-logo-bw}
	    
	    \vfill
	    
	    {\fontsize{21}{21}\selectfont \the@CVUTname}
	\end{titlingpage}

	\thispagestyle{empty}
	~
	\newpage
	\frontmatter
	\begin{titlingpage}
	
	    \vspace*{.2\textheight}
	    
		\begin{center}
		
% 			\vfill

			{\large\the@reportLabel{} \the@ReportID}
			
			\bigskip
			
			\textbf{\LARGE \thetitle}
			
			\bigskip
			
			{\LARGE\theauthor}
			
			\vfill
			
			{\large\the@published}
		    
		\end{center}
	    
	    \vfill
	    
	    \noindent\textcopyright{} \the@FITname\\
	    \the@CVUTname\\
	    \theFITaddress
	\end{titlingpage}

	\clearpage
	\tableofcontents*
	\mainmatter
	
	\maketitle
	
	\begin{abstract}
		\@theabstractL{}
	\end{abstract}
	
	
	\if\@lang1{
		\begin{otherlanguage}{english}
		    \begin{abstract}
		        \@theabstracten{}
		    \end{abstract}
		\end{otherlanguage}
	}\fi

	\paragraph{\if\@lang1{Kl{\' i}{\v c}ov{\' a} slova}\else{Keywords}\fi} \@thekeywordsL{}
	
	\if\@lang1{
		\begin{otherlanguage}{english}
			\paragraph{Keywords} \@thekeywordsen
		\end{otherlanguage}
	}\fi

	\clearpage
}
