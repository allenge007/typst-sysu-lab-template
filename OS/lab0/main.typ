#import "../../template.typ": *
#import "@preview/zebraw:0.4.5": *

#show: project.with(
  course: "操作系统原理实验",
  lab_name: "0x00",
  lab_name2: "环境搭建与实验准备",
  stu_name: "陈政宇",
  stu_num:  "23336003",
  major: "计算机科学与技术",
  watermark: "YatSenOS-v2",
  date: (2025, 3, 6),
  department: "东校园-实验中心大楼B201",
  show_content_figure: true,
)
#codly-enable()
// #show: zebraw
#codly(display-icon: false, zebra-fill: white)

// #show raw.where(block: true): box.with(fill: luma(240), inset: (x: 1.25em, y: 1em), width: 100%, radius: 4pt)

// #show raw.where(block: true): par.with(first-line-indent: 0em, justify: true, leading: 8pt)

// #show raw.where(block: false): box.with(
//     fill: luma(240),
//     inset: (x: 5pt, y: 0pt),
//     outset: (y: 4pt),
//     radius: 3pt,
//   )

= Rust 编程实践

== 任务一：文件读取

#task(title: "count_down(seconds: u64)")[
  该函数接收一个 u64 类型的参数，表示倒计时的秒数。函数应该每秒输出剩余的秒数，直到倒计时结束，然后输出 ```rust Countdown finished!```。
]\

利用简单的 for 循环和线程休眠实现倒计时功能，代码如下：

```rust
fn count_down(seconds: u64) {
    for i in (1..=seconds).rev() {
        println!("{} seconds left...", i);
        std::io::stdout().flush().unwrap();
        std::thread::sleep(std::time::Duration::from_secs(1));
    }
    info!("Count down finished!");
}
```\

#task(title: "read_and_print")[
该函数接收一个字符串参数，表示文件的路径。函数应该尝试读取并输出文件的内容。如果文件不存在，函数应该使用 `expect` 方法主动 panic，并输出 `File not found!`。
]\

采用了 ```rust std::fs::File::open``` 方法打开文件，然后使用 ```rust std::io::BufReader``` 读取文件内容。用 ```rust error!``` 宏记录错误日志，并使用 `?` 运算符将错误向上传播，代码如下：

```rust
fn read_and_print(file_path: &str) -> Result<(), std::io::Error> {
    let file = std::fs::File::open(file_path).map_err(|e| {
         error!("Failed to open file {}: {}", file_path, e);
         e
    })?;
    let reader = std::io::BufReader::new(file);
    for line in reader.lines() {
        println!("{}", line?);
    }
    info!("File read successfully!");
    Ok(())
}
```\

#task(title: "file_size")[
  该函数接收一个字符串参数，表示文件的路径，并返回一个 `Result`。
  函数应该尝试打开文件，并在 `Result` 中返回文件大小。如果文件不存在，函数应该返回一个包含 `File not found!` 字符串的 Err。
]\

实现方式与 read_and_print 基本一致，代码如下：

```rust
fn file_size(file_path: &str) -> Result<u64, std::io::Error> {
    let file = std::fs::File::open(file_path).map_err(|e| {
        error!("Failed to open file {}: {}", file_path, e);
        std::io::Error::new(std::io::ErrorKind::NotFound, "File not found!")
    })?;
    let mut reader = std::io::BufReader::new(file);
    let mut buffer = Vec::new();
    reader.read_to_end(&mut buffer)?;
    Ok(buffer.len() as u64)
}
```\

#task(title: "Final")[
  在 main 函数中，按照如下顺序调用上述函数：

+ 首先调用 count_down(5) 函数进行倒计时
+ 然后调用 read_and_print("/etc/hosts") 函数尝试读取并输出文件内容
+ 最后使用 std::io 获取几个用户输入的路径，并调用 file_size 函数尝试获取文件大小，并处理可能的错误。
]\

将上述代码合在 main 函数中分别调用即可，运行结果如图 1.1.1 所示#footnote[haha 文件并不存在，因此触发了异常处理机制]。

#grid(columns: 2,
  figure(
    image("./fig/1.png", width: 105%), caption: "任务一运行结果"
  ),
  figure(image("./fig/2.png", width: 105%), caption: "单元测试结果"),
)

== 任务二：代码单元测试

#task(title: "humanized_size")[
+ 将字节数转换为人类可读的大小和单位。使用 1024 进制，并使用二进制前缀（B, KiB, MiB, GiB）作为单位
+ 补全格式化代码，使得你的实现能够通过如下测试：
```rust
#[test]
fn test_humanized_size() {
    let byte_size = 1554056;
    let (size, unit) = humanized_size(byte_size);
    assert_eq!("Size :  1.4821 MiB", format!(/* FIXME */));
}
```
]\

一个简单的单位转换，函数的具体实现如下：

```rust
fn humanized_size(size: u64) -> (f64, &'static str) {
    let kb = 1024;
    let mb = kb * 1024;
    let gb = mb * 1024;
    let tb = gb * 1024;
    if size < kb {
        (size as f64, "B")
    } else if size < mb {
        ((size as f64) / kb as f64, "KiB")
    } else if size < gb {
        ((size as f64) / mb as f64, "MiB")
    } else if size < tb {
        ((size as f64) / gb as f64, "GiB")
    } else {
        ((size as f64) / tb as f64, "TiB")
    }
}
```\
 
测试代码补全如下：

```rust
#[test]
fn test_humanized_size() {
    let byte_size = 1554056;
    let (size, unit) = humanized_size(byte_size);
    assert_eq!("Size :  1.4821 MiB", format!("Size : {} {}", size, unit));
}
```\

测试通过，运行结果见图 1.1.2。

== 任务三：彩色文字终端

利用 ```rust Colored``` 库实现彩色文字终端。```rust Colored``` 库通过终端输出 ANSI 控制字符实现彩色文字显示。效果如图 1.1.3 所示 #footnote[具体代码可见4.1]。

#figure(image("./fig/3.png", width: 100%), caption: "彩色文字终端")

== 任务四：枚举类型

#task(title: "使用 enum 对类型实现同一化")[
  实现一个名为 `Shape` 的枚举，并为它实现 `pub fn area(&self) -> f64` 方法，用于计算不同形状的面积。
  - 你可能需要使用模式匹配来达到相应的功能
  - 请实现 `Rectangle` 和 `Circle` 两种 `Shape`，并使得 `area` 函数能够正确计算它们的面积
  - 使得你的实现能够通过如下测试：

      ```rust
      #[test]
      fn test_area() {
          let rectangle = Shape::Rectangle {
              width: 10.0,
              height: 20.0,
          };
          let circle = Shape::Circle { radius: 10.0 };

          assert_eq!(rectangle.area(), 200.0);
          assert_eq!(circle.area(), 314.1592653589793);
      }
      ```
]\

枚举类型是 Rust 中的一种复合类型，可以包含多种不同的值。在这里，我们定义了一个 `Shape` 枚下，包含了 `Rectangle` 和 `Circle` 两种形状。利用模式匹配，我们可以很方便地实现 `area` 方法，代码如下，单元测试通过#footnote[测试结果见图 1.1.2]。

```rust
enum Shape {
    Rectangle { width: f64, height: f64 },
    Circle { radius: f64 },
}
impl Shape {
    pub fn area(&self) -> f64 {
        match self {
            Shape::Rectangle { width, height } => width * height,
            Shape::Circle { radius } => std::f64::consts::PI * radius * radius,
        }
    }
}
```

== 任务五：元组结构体

#task(title: "现一个元组结构体 UniqueId(u16)")[
使得每次调用 `UniqueId::new()` 时总会得到一个新的不重复的 `UniqueId`。

- 你可以在函数体中定义 `static` 变量来存储一些全局状态
- 你可以尝试使用 `std::sync::atomic::AtomicU16` 来确保多线程下的正确性（无需进行验证，相关原理将在 Lab 5 介绍，此处不做要求）
- 使得你的实现能够通过如下测试：

```rust
#[test]
fn test_unique_id() {
    let id1 = UniqueId::new();
    let id2 = UniqueId::new();
    assert_ne!(id1, id2);
}
```
]\

注意到 `test` 中使用了 `assert_ne!` 宏，用于判断两个值是否不相等。因此我们需要有 `PartialEq` trait 的实现，可以用 `#[derive(PartialEq)]` 来自动生成。代码如下，单元测试通过#footnote[见图 1.1.2]。

```rust
#[derive(Debug, Eq, PartialEq)]
struct UniqueId(u16);
impl UniqueId {
    fn new() -> Self {
        static COUNTER: AtomicU16 = AtomicU16::new(0);
        UniqueId(COUNTER.fetch_add(1, Ordering::SeqCst))
    }
}
```

= YSOS，启动！

== 年轻人的第一个 UEFI 程序

使用 QEMU 启动 UEFI Shell 后，我们可以使用 Rust Toolchain 编译 UEFI 程序。下面是一个简单的 Hello World 程序，运行结果如图 2.1.4 所示。

```rust
#![no_std]
#![no_main]

#[macro_use]
extern crate log;
extern crate alloc;
use core::arch::asm;
use uefi::{Status, entry};

#[entry]
fn efi_main() -> Status {
    uefi::helpers::init().expect("Failed to initialize utilities");
    log::set_max_level(log::LevelFilter::Info);
    let std_num = "23336003";
    loop {
        info!("Hello World from UEFI bootloader! @ {}", std_num);
        for _ in 0..0x10000000 {
            unsafe {
                asm!("nop");
            }
        }
    }
}
```

#figure(image("./fig/4.png", width: 100%), caption: "UEFI 程序运行结果")

= 思考题

== 现代操作系统的启动流程

=== Windows系统启动过程解析

计算机的启动过程是一个精密的多阶段协作机制。当按下电源键后，系统经历以下关键阶段：

1. 电源通电自检（POST）

    电源管理系统完成供电后，固件立即执行POST流程。该过程会检测关键硬件组件（CPU、内存、存储控制器）的状态，并通过蜂鸣器代码或LED指示灯反馈检测结果。与传统BIOS的16位实模式检测不同，UEFI直接在32/64位保护模式下运行，显著提升硬件初始化效率。

2. 固件初始化阶段

    固件在此阶段建立基本硬件抽象层：
    - 枚举PCIe设备并分配资源
    - 初始化USB/SATA控制器
    - 构建ACPI表描述电源管理方案
    - 创建内存映射表（UEFI使用GUID分区表记录存储布局）

3. 引导加载程序阶段

    固件根据NVRAM中的引导条目定位引导分区。UEFI引入的ESP分区（EFI System Partition）采用FAT32文件系统，可直接访问引导文件（如\\EFI\\Boot\\bootx64.efi），而传统BIOS需要从MBR中读取512字节的引导扇区代码。

4. 操作系统加载阶段
    接由固件加载，而BIOS需要通过initrd映像传递驱动。

5. 系统初始化阶段

    内核启动会话管理器（smss.exe），依次加载注册表配置、系统服务（services.exe）和用户态环境（winlogon.exe）。此时UEFI的安全启动（Secure Boot）机制会验证所有引导组件的数字签名，防止rootkit注入。

=== UEFI与Legacy BIOS的技术差异

架构设计方面，UEFI采用模块化设计，支持驱动程序的动态加载。其服务分为引导服务（Boot Services）和运行时服务（Runtime Services），前者在操作系统加载后停止，后者持续提供硬件抽象。相比之下，BIOS工作在16位实模式，通过中断向量表（IVT）提供基本IO服务。

存储支持上，UEFI的GPT分区方案突破MBR的2TB容量限制，支持128个主分区，并通过冗余分区表提供数据可靠性。GPT头部的保护性MBR可防止传统磁盘工具误操作。

安全机制层面，UEFI 2.4引入的安全启动要求所有EFI可执行文件必须具有可信证书签名，有效抵御引导型恶意软件。配合TPM芯片还可实现全盘加密密钥的安全存储。

启动性能优化方面，UEFI通过并行硬件初始化和延迟驱动加载，可将启动时间缩短至10秒内。其内置的快速启动技术（Fast Boot）会跳过不必要的设备检测，直接复用上次启动的硬件配置快照。

发展趋势上，现代UEFI固件已集成网络堆栈和图形化配置界面，支持远程操作系统部署和故障诊断。而传统BIOS由于架构限制，正逐步退出历史舞台。

== Makefile 过程

== Cargo 包管理工具

== \#[entry] 与 main

= 附加题


== 彩色的日志

== Rust 实现简单 shell

== 线程模型