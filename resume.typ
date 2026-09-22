// Justin Meimar Resume
#set page(
  paper: "us-letter",
  margin: (x: 0.5in, y: 0.45in),
)

#set text(
  font: "New Computer Modern",
  size: 9.5pt,
)

#set par(justify: true, leading: 0.52em)

// Style all links: blue + underline
#show link: it => underline(text(fill: rgb("#1d4ed8"), it))

#let section(title) = {
  v(6pt)
  text(weight: "bold", size: 10.5pt)[#upper(title)]
  v(-3pt)
  line(length: 100%, stroke: 0.5pt)
  v(1pt)
}

#let entry(title, subtitle: none, location: none, date: none, body) = {
  block(breakable: false)[
    #grid(
      columns: (1fr, auto),
      align: (left, right),
      {
        text(weight: "bold")[#title]
        if subtitle != none [ | #subtitle]
        if location != none [ #text(style: "italic")[(#location)]]
      },
      if date != none [#text(style: "italic")[#date]]
    )
    #v(1pt)
    #body
    #v(2pt)
  ]
}

// Header
#align(center)[
  #text(size: 18pt, weight: "bold")[Justin Meimar]
  #v(0.5pt)
  #text(size: 9pt)[
    #link("mailto:meimar@ualberta.ca")[meimar\@ualberta.ca] #h(8pt)
    #link("https://github.com/JustinMeimar")[GitHub]
  ]
  #v(0.5pt)
  #text(size: 8.5pt, fill: rgb("#666"))[Systems Software Engineer | Edmonton, Alberta, Canada]
]

#v(0pt)

#section("Education")

*University of Alberta* - Thesis-Based MSc. Computer Science #h(1fr) _Sep 2025 – Aug 2027_\
GPA: 3.8 / 4.0\
Key Classes: Formal Verification, Advanced Compiler Design, Machine Learning II, Convex Optimization.

#v(4pt)

*University of Alberta* - BSc. Spec. Computer Science #h(1fr) _Sep 2021 – April 2025_\
GPA: 3.7 / 4.0\
Key Classes: Algorithms, Compilers, Software Engineering, Operating Systems, Computer Vision & Machine Learning.

#v(2pt)

#section("Experience")

#entry(
  "Research Assistant",
  subtitle: "Compiler Design Optimization Lab — Mozilla-sponsored",
  location: "Edmonton, Alberta",
  date: "Sep 2025 – Present"
)[
  - Designed and implemented AmberMonkey, an AOT code-generation target in SpiderMonkey that reuses Baseline and inline-cache JIT artifacts across processes.
]

#entry(
  "Tensor Compiler Intern",
  subtitle: "Huawei",
  location: "Edmonton, Alberta",
  date: "May – Aug 2025"
)[
  - Designed scheduling algorithms using hardware heuristic-guided search to efficiently lower tiled computation graphs to custom matrix accelerators.
]

#entry(
  "Teaching Assistant",
  subtitle: "University of Alberta",
  location: "Edmonton, Alberta",
  date: "Jan 2023 – Dec 2025"
)[
  - Head TA for CMPUT 415 Compiler Design (Fall 2024 and 2025), teaching LLVM, MLIR, and practical compiler development.
  - TA for CMPUT 429 and 229 Computer Architecture (Winter 2024 and 2023), including RISC-V assembly programming.
]

#entry(
  "Summer Research Intern",
  subtitle: "Compiler Design Optimization Lab",
  location: "Edmonton, Alberta",
  date: "May – Aug 2024"
)[
  - Researched copy-and-patch JITs; upgraded compilers to LLVM 18 and added MLIR dialects and lowerings.
]

#entry(
  "Full Stack Intern",
  subtitle: "Bits in Glass",
  location: "Edmonton, Alberta",
  date: "May – Aug 2023"
)[
  - Developed an internal web tool in Python and managed deployment on Heroku with Docker.
]

#section("Projects")

#entry(
  "Hack GPT Edmonton",
  subtitle: [1st Place],
  date: "July 2023"
)[
  - Hackathon - Worked in a team of four to build an interactive information retrieval system for Real Estate listings using Vector-Embeddings and LLM (large language model) APIs.
]

#entry(
  "Home Server",
  subtitle: "System Administration",
  date: "June 2023"
)[
  - Managed a small server with NGINX to host services over SSH and HTTPs.
]

#entry(
  "Gazprea Compiler",
  subtitle: [1st Place],
  date: "Fall 2022"
)[
  - Worked in a team of four to create a tournament winning compiler; focused on type-checking, type-promotion, and control flow implementation using LLVM IR-builder.
]



#block(breakable: false)[
  #section("Stack")

  *Compiler & Systems* / JIT and AOT Compilation - Code Generation - Performance Analysis - Linux

  *Tools* / LLVM - MLIR - Git - CMake - GDB - Valgrind - Docker

  *Languages* / C++ - C - Python - JavaScript - TypeScript - Rust - Bash - SQL
]
