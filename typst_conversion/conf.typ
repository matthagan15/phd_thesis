// University of Toronto Thesis Typst Template
#set text(font: "New Computer Modern")
#let chapter_counter = 0
#let chapter(
    name,
) = {
    // glob.get_mut(chapter_counter) += 1
    text(
        [Chapter #h(2pt)] + $x$,
        weight: "bold",
    )
}

// Page Configuration
#let page-setup(
    margin-size: (
        left: 32mm, // Left margin 1 1/4" (32 mm)
        other: 20mm, // Other margins 3/4" (20 mm)
    ),
) = {
    set page(
        paper: "us-letter",
        margin: (
            left: margin-size.left,
            right: margin-size.other,
            top: margin-size.other,
            bottom: margin-size.other,
        ),
    )

    // Line spacing: at least 1.5
    set par(leading: 1.5em)
}

// Main Document Structure
#let ut-thesis(
    title: "Thesis Title",
    author: "Author Name",
    degree: "Doctor of Philosophy",
    department: "Graduate Department",
    graduation-year: datetime.today().year(),
    body,
) = {
    // Page setup
    page-setup()

    // Title Page (no numbering, centered)
    page(
        // Approximate positioning based on guidelines
        margin: (top: 2in, bottom: 1.25in),
        align(center)[
            #v(0pt)
            #text(size: 12pt)[#smallcaps[#title]]

            #v(1.5in)
            by

            #v(1.5in)
            #text(size: 12pt)[#author]

            #v(2in)
            A thesis submitted in conformity with the requirements \
            for the degree of Doctor of Philosophy\
            Department of Physics \
            University of Toronto

            #v(1.25in)
            © Copyright by #author #graduation-year
        ],
    )

    // Preliminary pages with Roman numerals
    set page(
        numbering: "i",
        number-align: center,
    )

    // Abstract (double-spaced, max 350 words for doctoral thesis)
    page[
        #align(center)[
            #v(1em)
            #text(size: 12pt)[
                #title\
                #v(0.075cm)
                #author\
                #degree\
                #v(0.075cm)
                Department of Physics \
                University of Toronto\
                #graduation-year
            ] \
            #text(size: 14pt, weight: "bold")[Abstract]
        ]

        #set par(leading: 2em) // Double-spaced
        // Placeholder for abstract content
        // Actual content should be added by the user
        #lorem(100)
    ]

    page[
        #place(horizon + right, "To my siblings.")
    ]

    page[
        #align(
            center,
            text(size: 14pt, weight: "bold", [Acknowledgements]),
        )
    ]

    page[
        #outline()
    ]

    // Optional lists (user can customize/remove as needed)
    page[
        #outline(title: "List of Figures", target: figure.where(kind: image))
    ]

    page[
        #outline(title: "List of Tables", target: figure.where(kind: table))
    ]

    // Main document body with Arabic numerals
    set page(numbering: "1")

    // Render the body of the document
    body
}
