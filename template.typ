#import "@preview/codly:1.2.0": *
#import "@preview/codly-languages:0.1.7": *
#import "@preview/i-figured:0.2.4"
#import "@preview/pintorita:0.1.3"
#import "@preview/gentle-clues:1.2.0": *
#import "@preview/cheq:0.2.2": checklist
#import "@preview/unify:0.7.1": num, qty, numrange, qtyrange
#import "@preview/thmbox:0.2.0": *
#import "@preview/hydra:0.6.0": hydra

#let Heiti = ("Times New Roman", "Heiti SC", "Heiti TC", "Hei")
#let Songti = ("Times New Roman", "Songti SC", "Songti TC", "簡宋")
#let Zhongsong = ("Times New Roman", "STFangsong", "簡宋")
#let Xbs = ("Times New Roman", "FandolSong", "簡宋")

#let indent() = {
  box(width: 2em)
}

#let info_key(body) = {
  rect(width: 100%, inset: 2pt, stroke: none, text(font: Heiti, weight: "extrabold", size: 14pt, body))
}

#let info_value(body) = {
  rect(
    width: 100%,
    inset: 1pt,
    stroke: (bottom: black),
    text(font: Heiti, weight: "light", size: 14pt, bottom-edge: "descender")[ #body ],
  )
}

#let project(
  course: "",
  lab_name: "LAB NAME",
  lab_name2: "编译内核/利用已有内核构建OS",
  stu_name: "NAME",
  stu_num: "1234567",
  major: "MAJOR",
  department: "DEPARTMENT",
  grade: "",
  date: (2077, 1, 1),
  show_content_figure: false,
  watermark: "SYSU",
  body,
) = {
  set page("a4")
  // 封面
  align(center)[
    #v(35pt)
    #image("./img/sysu-logo.svg", width: 30%)
    #v(30pt)
    #set text(
      size: 26pt,
      font: Songti,
      weight: "bold",
    )

    // 课程名
    #text(size: 26pt, font: Heiti, weight: "bold")[
      课 程 实 验 报 告
    ]
    #v(48pt)
    // 报告名
    #text(size: 22pt, font: Heiti, weight: "black")[
      #lab_name
    ]
    #text(size: 22pt, font: Heiti, weight: "thin")[
      #lab_name2
    ]
    #v(48pt)
    // 个人信息
    #grid(
      columns: (3em, 10em),
      rows: (30pt, 30pt),
      gutter: 1pt,
      // info_key(""),
      // info_value(major),
      info_key("课程名称"),
      info_value(course),
      info_key("专业名称"),
      info_value(major),
      info_key("学生姓名"),
      info_value(stu_name),
      info_key("学生学号"),
      info_value(stu_num),
      info_key("实验地点"),
      info_value(department),
      info_key("实验成绩"),
      info_value(grade),
      info_key("实验日期"),
      rect(
        width: 100%,
        inset: 1pt,
        stroke: (bottom: black),
        text(font: Heiti, weight: "light", size: 14pt, bottom-edge: "descender")[ #date.at(0) 年 #date.at(1) 月 #date.at(2) 日 ],
      )
    )
  ]
  pagebreak()

  // 目录
  show outline.entry.where(level: 1): it => {
    v(14pt, weak: true)
    strong(it)
  }
  show outline.entry: it => {
    set text(
      font: Xbs,
      size: 14pt,
    )
    it
  }
  outline(
    title: text(font: Xbs, size: 20pt)[目录],
    indent: auto,
  )
  if show_content_figure {
    text(font: Xbs, size: 10pt)[
      #i-figured.outline(title: [图表])
    ]
  }
  // TOC
  pagebreak()

  // 页眉页脚设置
  set page(
    header: context {
        set text(font: Xbs)
        align(left, [#course -- #lab_name])
        v(-0.9cm)
        align(right, hydra(2))
        line(length: 100%) 
        v(5pt)
    },
    footer: context [
      #set align(center)
      #counter(page).display(
        "1/1",
        both: true,
      )
    ]
  )

  // 正文设置
  show: thmbox-init()
  set heading(numbering: "1.1")
  set figure(supplement: [图])
  show heading: i-figured.reset-counters.with(level: 2)
  show figure: i-figured.show-figure.with(level: 2)
  show math.equation: i-figured.show-equation
  set text(
    font: Songti,
    size: 12pt,
  )
  set par(    // 段落设置
    justify: false,
    leading: 1.04em,
    first-line-indent: 2em,
  )
  show heading: it => box(width: 100%)[ // 标题设置
    #v(0.45em)
    #set text(font: Xbs)
    #if it.numbering != none {
      counter(heading).display()
    }
    #h(0.75em)
    #it.body
    #v(5pt)
  ]
  show link: it => {          // 链接
    set text(fill: blue.darken(20%))
    it
  }
  show: gentle-clues.with(    // gentle块
    headless: false, // never show any headers
    breakable: true, // default breaking behavior
    header-inset: 0.4em, // default header-inset
    content-inset: 1em, // default content-inset
    stroke-width: 2pt, // default left stroke-width
    border-radius: 2pt, // default border-radius
    border-width: 0.5pt, // default boarder-width
  )
  show: checklist.with(fill: luma(95%), stroke: blue, radius: .2em)   // 复选框

  // 代码段设置
  show: codly-init.with()
  codly(languages: codly-languages)
  show raw.where(lang: "pintora"): it => pintorita.render(it.text)

  // 水印
  set page(background: rotate(-60deg,
  text(100pt, fill: rgb("#eff9f1"))[
      #strong()[#watermark]
    ]
  ))

  body
}