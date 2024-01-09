
基于HVS的RDH方法
=======


论文名： "[Human Visual System Guided Reversible Data Hiding Based On Multiple Histograms Modification](https://academic.oup.com/comjnl/article/66/4/888/6503940)" (2023年发表于The Computer Journal).

## 方法简介

基于MHM框架，提出了一个以人眼视觉系统为优化对象的RDH方法，该方法不以PSNR作为质量评价，而是面向SSIM、JNDD和WPSNR这三个主观质量得分设计嵌入方案


<p align="center"> <img src="./results/work.jpg" width="100%">    </p>
<p align="center"> 图1: 数据嵌入框架. </p>


<p align="center"> <img src="./results/Rollback.jpg" width="100%">    </p>
<p align="center"> 图2: 提出的参数回滚机制. </p>



## 如何运行

下载本项目源代码

```
运行 main.m 文件 
```

## 实验结果

<p align="center"> <img src="./results/Table.jpg" width="100%">    </p>
<p align="center"> 图3: SSIM, WPSNR 和 JNDD 的对比结果. </p>

<p align="center"> <img src="./results/kodak.jpg" width="100%">    </p>
<p align="center"> 图4: Kodak数据库中的WPSNR结果.</p>

<p align="center"> <img src="./results/region.jpg" width="100%">    </p>
<p align="center"> 图5: 嵌入区域对比. </p>


## 实验环境
Matlab 2016b <br>


## 致谢
这项工作由中国国家自然科学基金（NSFC）支持，基金号：Nos. 61872128, 61972031, U1736213.



## 引用格式
如果这项工作对您的研究有帮助, 请按如下格式引用：
```
@ARTICLE{9605567,
  author={Zhang, Cheng and Ou, Bo and Li, Xiaolong and Xiong, Jianqin},
  journal={The Computer Journal}, 
  title={Human Visual System Guided Reversible Data Hiding Based On Multiple Histograms Modification}, 
  year={2023},
  volume={66},
  number={4},
  pages={888-906},
  doi={10.1093/comjnl/bxab203}}
```

## 版权声明
本项目已开源 (详见 ``` MIT LICENSE ``` ).

