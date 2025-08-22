---
title: 房地产相关的零碎数据
author: 黄湘云
date: '2025-08-20'
slug: real-estate
categories:
  - 商业思维
tags:
  - 中国房地产
  - 中国 GDP
  - 人均住宅面积
  - echarts
  - Hugo
---


{{<toc>}}


# GDP 及其增长率

数据来源：中华人民共和国住房和城乡建设部[2023年城市建设统计年鉴](https://www.mohurd.gov.cn/gongkai/fdzdgknr/sjfb/tjxx/jstjnj/index.html)。


1978-2023 国内生产总值 GDP 及增长速度，这是自改革开放以来衡量国民经济发展情况的核心指标之一，也是人民大众中最常听到的经济指标。


{{<echarts>}}
const colors = ['#5070dd', '#b6d634'];
option = {
  color: colors,
  tooltip: {
    trigger: 'axis',
    axisPointer: {
      type: 'cross'
    }
  },
  grid: {
    right: '20%'
  },
  toolbox: {
    feature: {
      dataView: { show: true, readOnly: false },
      restore: { show: true },
      saveAsImage: { show: true }
    }
  },
  legend: {
    data: ['国内生产总值', '增长速度']
  },
  xAxis: [
    {
      type: 'category',
      axisTick: {
        alignWithLabel: true
      },
      // prettier-ignore
      data: ['1978', '1979', '1980', '1981', '1982', '1983', '1984', '1985', '1986', '1987', '1988',
      '1989', '1990', '1991', '1992', '1993', '1994', '1995', '1996', '1997', '1998', '1999', '2000',
      '2001', '2002', '2003', '2004', '2005', '2006', '2007', '2008', '2009', '2010', '2011', '2012', '2013', '2014', '2015', '2016', '2017', '2018', '2019', '2020', '2021', '2022', '2023']
    }
  ],
  yAxis: [
  {
    type: 'value',
    name: '国内生产总值',
    position: 'left',
    alignTicks: true,
    axisLine: {
      show: true,
      lineStyle: {
        color: colors[0]
      }
    },
    axisLabel: {
      formatter: '{value} 亿元'
    }
  },
      {
    type: 'value',
    name: '增长速度',
    position: 'right',
    alignTicks: true,
    axisLine: {
      show: true,
      lineStyle: {
        color: colors[1]
      }
    },
    axisLabel: {
      formatter: '{value} %'
    }
  }
  ],
  series: [
    {
      name: '国内生产总值',
      type: 'bar',
      yAxisIndex: 0,
      data: [
        3678.7, 4100.5, 4587.6, 4935.8, 5373.4, 6020.9, 7278.5, 9098.9, 10376.2, 12174.6, 15180.4, 17179.7, 18872.9, 22005.6, 27194.5, 35673.2, 48637.5, 61339.9, 71813.6, 79715.0, 85195.5, 90564.4,
        100280.1, 110863.1, 121717.4, 137422.0, 161840.2, 187318.9, 219438.5, 270232.3, 319515.5, 349081.4, 413030.3, 489300.6, 540367.4, 595244.4, 643974.0, 689052.1, 744127.2, 827122.0, 900309.0, 990865.0, 1013567.0, 1149237.0, 1204724.0, 1260582.0
        ]
    },
    {
      name: '增长速度',
      type: 'line',
      yAxisIndex: 1,
      data: [11.7, 7.6, 7.8, 5.1, 9.0, 10.8, 15.2, 13.4, 8.9, 11.7, 11.2, 4.2, 3.9, 9.3, 14.2, 13.9, 13.1, 11.0, 9.9, 9.2, 7.8, 7.7, 8.5, 8.3, 9.1, 10.0, 10.1, 11.4, 12.7, 14.2, 9.7, 9.4, 10.6, 9.5, 7.9, 7.8, 7.3, 6.9, 6.7, 6.9, 6.6, 6.1, 2.2, 8.4, 3.0, 5.2]
    }
  ]
};
{{</echarts>}}

GDP 增长率指标中有几个重大拐点。

- 1981 年计划和市场价格双轨制带来的「官倒」，导致经济混乱。
- 1989 年春夏之交发生的政治风波，持续影响到 1990 年，1991-1992 年恢复。
- 2020 年受新冠疫情影响。
- 2022 年受动态清零政策影响。

# 人均住宅面积（村镇）

数据来源：中华人民共和国住房和城乡建设部[2023年城市建设统计年鉴](https://www.mohurd.gov.cn/gongkai/fdzdgknr/sjfb/tjxx/jstjnj/index.html)。

注意：人均住宅面积的数据在2023年统计年鉴的城市部分、县城部分都没有找到，只有在村镇部分中披露。就是说，人均住宅面积这个数据，只有村镇的，没有城市和县城的。

我是在 2008 年考上省重点高中以后，陆陆续续断了和老家（农村）的联系，再也没有回去住过，那是一家四口挤在 30 平米的房子中，房子中间放了六门的大衣柜，兼作卧室和客厅的隔断，人均住宅面积不足 8 平米。2024年 11 月下旬，回到农村，目之所及，据说都是最近 10 年陆续建成的新房子。（肉眼观察）粗算下来，人均居住面积不低于 40 平米，这其实已经很好的居住条件了。而在县城里，一家三口（或四口）住 140-150 平米的房子，也很不错了。


{{<echarts>}}
const colors2 = ['#5070dd', '#b6d634', '#505372'];
option = {
  color: colors2,
  tooltip: {
    trigger: 'axis',
    axisPointer: {
      type: 'cross'
    }
  },
  grid: {
    right: '20%'
  },
  toolbox: {
    feature: {
      dataView: { show: true, readOnly: false },
      restore: { show: true },
      saveAsImage: { show: true }
    }
  },
  legend: {
    data: ['人均住宅建筑面积', '年末实有住宅建筑面积', '建成区户籍人口']
  },
  xAxis: [
    {
      type: 'category',
      axisTick: {
        alignWithLabel: true
      },
      // prettier-ignore
      data: ['1990', '1991', '1992', '1993', '1994', '1995', '1996', '1997', '1998', '1999', '2000',
      '2001', '2002', '2003', '2004', '2005', '2006', '2007', '2008', '2009', '2010', '2011', '2012', '2013', '2014', '2015', '2016', '2017', '2018', '2019', '2020', '2021', '2022', '2023']
    }
  ],
  yAxis: [
    {
      type: 'value',
      name: '人均住宅建筑面积',
      position: 'left',
      alignTicks: true,
      axisLine: {
        show: true,
        lineStyle: {
          color: colors2[0]
        }
      },
      axisLabel: {
        formatter: '{value} 平方米'
      }
    },
    {
      type: 'value',
      name: '年末实有住宅建筑面积',
      position: 'right',
      alignTicks: true,
      axisLine: {
        show: true,
        lineStyle: {
          color: colors2[1]
        }
      },
      axisLabel: {
        formatter: '{value} 亿平方米'
      }
    },
    {
      type: 'value',
      name: '建成区户籍人口',
      position: 'right',
      alignTicks: true,
      offset: 80,
      axisLine: {
        show: true,
        lineStyle: {
          color: colors2[2]
        }
      },
      axisLabel: {
        formatter: '{value} 亿人'
      }
    }
  ],
  series: [
    {
      name: '人均住宅建筑面积',
      type: 'line',
      yAxisIndex: 0,
      data: [
        19.9, 19.8, 20.5, 20.2, 20.6, 20.7, 21.1, 21.5, 21.8, 22.0, 22.6, 22.7, 23.2, null, 24.1, 25.7, 27.9, 29.7, 30.1, 32.1, 32.5, 33.0, 33.6, 34.1, 34.6, 34.6, 34.9, 34.8, 36.1, 36.5, 37.0, 38.1, 39.2, 40.0
      ]
    },
    {
      name: '年末实有住宅建筑面积',
      type: 'line',
      yAxisIndex: 1,
      data: [
        12.3, 12.9, 14.8, 15.8, 17.6, 18.9, 20.5, 21.8, 23.3, 24.8, 27.0, 28.6, 30.7, null, 33.7, 36.8, 39.1, 38.9,41.5, 44.2, 45.1, 47.3, 49.6, 52.0, 54.0, 55.4, 56.7, 53.9, 57.9, 60.4, 61.4, 63.2, 65.2, 66.1
      ]
    },
    {
      name: '建成区户籍人口',
      type: 'line',
      yAxisIndex: 2,
      data: [
        0.61, 0.66, 0.72, 0.79, 0.87, 0.93, 0.99, 1.04, 1.09, 1.16, 1.23, 1.30, 1.37, null, 1.43, 1.48, 1.40, 1.31, 1.38, 1.38, 1.39, 1.44, 1.48, 1.52, 1.56, 1.60, 1.62, 1.55, 1.61, 1.65, 1.66, 1.66, 1.66, 1.65
      ]
    }
  ]
};
{{</echarts>}}


- 2003 年的数据缺失（或者说未公布）。
- 可以看到 2004 年开始，人均住宅建筑面积有一个极速上升的阶段，一直冲到 2008 年。2008 年发生次贷危机。
- 可以看到 2017 年是一个向下的拐点，史上最强调控政策「3·17新政」出台，限购、限贷、限价、限售、限商。「房住不炒」定位。
- 还可以看到 2018 年及之后，人均住宅建筑面积又有一个快速上升的阶段，一直到现在。

当资金有限，城里买房和老家建房只能二选一时，回老家建房的性价比更好，风险更小。而这样做，本来有能力和意愿在城里买房的人（接盘）不去接盘了，城里的楼市风险更难以化解了。当然，这部分在农村建房的人也要面临子女教育问题，农村大部分地方的中小学已经快没了。


# 城镇登记/调查失业率（北京）

数据来源：北京市人民政府[年度统计公报](https://www.beijing.gov.cn/gongkai/shuju/tjgb/)。

一般地，一个地区的 GDP 增速很高，往往失业率比较低。城镇调查失业率事关收入，收入状况影响购房能力。下面看看北京的 GDP 及其增长率，以及城镇登记/调查失业率。


{{<echarts>}}
// const colors2 = ['#5070dd', '#b6d634', '#505372'];
option = {
  color: colors2,
  tooltip: {
    trigger: 'axis',
    axisPointer: {
      type: 'cross'
    }
  },
  grid: {
    right: '20%'
  },
  toolbox: {
    feature: {
      dataView: { show: true, readOnly: false },
      restore: { show: true },
      saveAsImage: { show: true }
    }
  },
  legend: {
    data: ['北京GDP', 'GDP增长率', '城镇登记/调查失业率']
  },
  xAxis: [
    {
      type: 'category',
      axisTick: {
        alignWithLabel: true
      },
      // prettier-ignore
      data: ['2007', '2008', '2009', '2010', '2011', '2012', '2013', '2014', '2015', '2016', '2017', '2018', '2019', '2020', '2021', '2022', '2023', '2024']
    }
  ],
  yAxis: [
    {
      type: 'value',
      name: '北京GDP',
      position: 'left',
      alignTicks: true,
      axisLine: {
        show: true,
        lineStyle: {
          color: colors2[0]
        }
      },
      axisLabel: {
        formatter: '{value} 亿元'
      }
    },
    {
      type: 'value',
      name: 'GDP增长率',
      position: 'right',
      alignTicks: true,
      axisLine: {
        show: true,
        lineStyle: {
          color: colors2[1]
        }
      },
      axisLabel: {
        formatter: '{value} %'
      }
    },
    {
      type: 'value',
      name: '城镇登记/调查失业率',
      position: 'right',
      alignTicks: true,
      offset: 80,
      axisLine: {
        show: true,
        lineStyle: {
          color: colors2[2]
        }
      },
      axisLabel: {
        formatter: '{value} %'
      }
    }
  ],
  series: [
    {
      name: '北京GDP',
      type: 'bar',
      yAxisIndex: 0,
      data: [
        9006.2, 10488, 11865.9, 13777.9, 16000.4, 17801, 19500.6, 21330.8, 22968.6, 24899.3, 28000.4, 30320, 35371.3, 36102.6, 40269.6, 41610.9, 43760.7, 49843.1
      ]
    },
    {
      name: 'GDP增长率',
      type: 'line',
      yAxisIndex: 1,
      data: [
        12.3, 9, 10.1, 10.2, 8.1, 7.7, 7.7, 7.3, 6.9, 6.7, 6.7, 6.6, 6.1, 1.2, 8.5, 0.7, 5.2, 5.2
      ]
    },
    {
      name: '城镇登记/调查失业率',
      type: 'line',
      yAxisIndex: 2,
      data: [
        1.84, 1.82, 1.44, 1.37, 1.39, 1.27, 1.21, 1.31, 1.39, 1.41, 1.43, 1.42, 1.41, 4.1, null, 4.7, 4.4, 4.1
      ]
    }
  ]
};
{{</echarts>}}


注意：城镇登记失业率：2007-2017。城镇调查失业率（分季度统计）：2018-2024。中国城镇登记失业率警戒线为 4%（未包含农村劳动力），若突破可能引发政策调整。

- 2018：4.2%、4.2%、4.4%和3.9%
- 2019：4.0%、4.2%、4.2%和4.0%
- 2020：4季度4.1%
- 2021：不公布
- 2022-2024：均值分别为为4.7%、4.4%、4.1%

2016 年及以前楼市疯狂上蹿，经济存在过热，「房住不炒」出台政策限购，抑制过热现象。2020-2022 年发生疫情，叠加清零政策，失业率高企。2022 年底取消动态清零政策，2023 年 GDP 增速未恢复至疫情前，失业率维持在 4% 以上。GDP 过热现象抑制了，但是失业率居高不下了。



# 房地产行业

北京市、邵东市年度房地产开发投资额及其增长率、以及占全年固定资产投资（不含农户）的比重。

## 北京市 2007-2024

数据来源：北京市人民政府[年度统计公报](https://www.beijing.gov.cn/gongkai/shuju/tjgb/)。

北京是中国的首都，经济发展水平相对全国来说都处在第一梯队的前沿，北京是全国房地产行业动向的风向标，所以，北京要拎出来单独看看。投资、消费和外贸是拉动经济增长的三驾马车，对北京，下图展示房地产开发投资额及其增长率，以及占全年固定资产投资（不含农户）的比重。

{{<echarts>}}
// const colors2 = ['#5070dd', '#b6d634', '#505372'];
option = {
  color: colors2,
  tooltip: {
    trigger: 'axis',
    axisPointer: {
      type: 'cross'
    }
  },
  grid: {
    right: '20%'
  },
  toolbox: {
    feature: {
      dataView: { show: true, readOnly: false },
      restore: { show: true },
      saveAsImage: { show: true }
    }
  },
  legend: {
    data: ['房地产开发投资', '增长率', '占总投资的比重']
  },
  xAxis: [
    {
      type: 'category',
      axisTick: {
        alignWithLabel: true
      },
      // prettier-ignore
      data: ['2007', '2008', '2009', '2010', '2011', '2012', '2013', '2014', '2015', '2016', '2017', '2018', '2019', '2020', '2021', '2022', '2023', '2024']
    }
  ],
  yAxis: [
    {
      type: 'value',
      name: '房地产开发投资',
      position: 'left',
      alignTicks: true,
      axisLine: {
        show: true,
        lineStyle: {
          color: colors2[0]
        }
      },
      axisLabel: {
        formatter: '{value} 亿元'
      }
    },
    {
      type: 'value',
      name: '增长率',
      position: 'right',
      alignTicks: true,
      axisLine: {
        show: true,
        lineStyle: {
          color: colors2[1]
        }
      },
      axisLabel: {
        formatter: '{value} %'
      }
    },
    {
      type: 'value',
      name: '占总投资的比重',
      position: 'right',
      alignTicks: true,
      offset: 80,
      axisLine: {
        show: true,
        lineStyle: {
          color: colors2[2]
        }
      },
      axisLabel: {
        formatter: '{value} %'
      }
    }
  ],
  series: [
    {
      name: '房地产开发投资',
      type: 'bar',
      yAxisIndex: 0,
      data: [
        1995.8, 1908.7, 2337.7, 2901.1, 3036.3, 3153.4, 3483.4, 3911.3, 4226.3, 4045.4, 3745.9, 3873.26, 3838.4, 3938.2, 4139.0, 4180.4, 4197.1, 3752.2
      ]
    },
    {
      name: '增长率',
      type: 'line',
      yAxisIndex: 1,
      data: [
        16, -4.4, 22.5, 24.1, 10.1, 3.9, 10.5, 12.3, 8.1, -4.3, -7.4, 3.4, -0.9, 2.6, 5.1, 1.0, 0.4, -10.6
      ]
    },
    {
      name: '占总投资的比重',
      type: 'line',
      yAxisIndex: 2,
      data: [
        100*1995.8/3966.6, 100*1908.7/3848.5, 100*2337.7/4858.4, 100*2901.1/5493.5, 100*3036.3/5910.6, 100*3153.4/6462.8, 100*3483.4/7032.2, 100*3911.3/7562.3, 100*4226.3/7990.9, 100*4045.4/8461.7, 100*3745.9/8948.1, 100*3873.26/8062.2, 100*3838.4/7868.7, 100*3938.2/8041.8, 100*4139/8435.8, 100*4180.4/8739.5, 100*4197.1/9167.7, 100*3752.2/9635.3
      ]
    }
  ]
};
{{</echarts>}}


拉动经济增长靠投资，房地产开发投资占比总投资的比重，这个指标很重要，对经济影响很大。一旦有明显波动，需要仔细看。

- 2007-2016 年间房地产开发投资占比总投资的比重基本维持在 49% 左右，2018-2021 又开始恢复至 49% 左右，2021至今的近几年稳中有跌，2024 年跌幅最大。
- 2007-2015 年间房地产开发投资额翻了一倍。2016 年最强限购政策出台，房地产开发投资额应声下降，且在 2017 年其占总投资额的比例降至历史最低点 41.8%。

房地产开发和销售的主要指标，商品房施工面积、商品房新开工面积、商品房竣工面积和商品房销售面积，面积单位（万平方米）。

{{<echarts>}}
var _currentAxisBreaks = [
  {
    start: 4500,
    end: 9000,
    gap: '1.5%'
  }
];
option = {
  title: {
    text: '北京市房地产开发和销售 2007-2024',
    left: 'center',
    textStyle: {
      fontSize: 20
    },
    subtextStyle: {
      color: '#175ce5',
      fontSize: 15,
      fontWeight: 'bold'
    }
  },
  tooltip: {
    trigger: 'axis',
    axisPointer: {
      type: 'shadow'
    }
  },
  legend: {},
  grid: {
    top: 120
  },
  xAxis: [
    {
      type: 'category',
      data: ['2007', '2008', '2009', '2010', '2011', '2012', '2013', '2014', '2015', '2016', '2017', '2018', '2019', '2020', '2021', '2022', '2023', '2024']
    }
  ],
  yAxis: [
    {
      type: 'value',
      breaks: _currentAxisBreaks,
      breakArea: {
        itemStyle: {
          opacity: 1
        },
        zigzagZ: 200
      }
    }
  ],
  series: [
    {
      name: '施工面积',
      type: 'line',
      emphasis: {
        focus: 'series'
      },
      data: [10438.6, 10014.3, 9719.1, 10300.9, 12065.4, 13122.5, 13886.9, 13641.5, 13095.0, 13089.8, 12608.6, 12962.6, 12515.0, 13918.6, 14055.3, 13333.1, 12531.3, 11309.5]
    },
    {
      name: '新开工面积',
      type: 'line',
      emphasis: {
        focus: 'series'
      },
      data: [null, null, 2246.6, 2974.2, 4246.1, null, 3577.5, 2502.8, 2790.2, 2813.7, 2475.7, 2321.1, 2073.2, 3006.6, 1895.9, 1774.4, 1257.1, 1286.9]
    },
    {
      name: '竣工面积',
      type: 'line',
      emphasis: {
        focus: 'series'
      },
      data: [2891.7, 2558, 2678.6, 1639.5, 2245.2, 2390.9, 2666.4, 3054.1, 2631.5, 2383.1, 1466.7, 1557.9, 1343.3, 1545.7, 1983.9, 1938.5, 2042.2, 1652.5]
    },
    {
      name: '销售面积',
      type: 'line',
      data: [2176.6, 1335.4, 2362.3, 1482.7, 1440, 1943.7, 1903.1, 1459.0, 1554.7, 1675.1, 875.0, 696.2, 938.9, 970.9, 1107.1, 1040.0, 1122.6, 1118.7],
      emphasis: {
        focus: 'series'
      }
    },
    {
      name: '待售面积',
      type: 'line',
      data: [1136.2, 1438.3, 1351.4, 1482.7, 1792.6, 1911.8, 1903.1, 2065.7, 2168.1, 2160.8, 2092.1, 2153.3, 2489.5, null, 2396.3, 2617.0, 2949.9, 3251.8],
      emphasis: {
        focus: 'series'
      }
    }
  ]
};

{{</echarts>}}

注意：2007、2008 和 2011 年新开工面积未公布，2020 年待售面积未公布。

从图中，不难看出，受疫情影响，施工面积在减少，保交楼政策下，开发商资金紧张，新开工面积在减少，待售面积在增加，库存压力在增大。

## 邵东市 2007-2024

数据来源：邵东市人民政府[统计信息](https://www.shaodong.gov.cn/shaodong/tjxx/list2.shtml)和[邵阳市统计局](https://tjj.shaoyang.gov.cn)。邵东市是邵阳市代管的县级市。

邵东市 GDP 及其增速，以及全市全社会固定资产投资总额的增速。城市基础设施投资与房地产投资是相辅相成的紧密关系。道路、水电、学校、商业中心等建设可以使得地皮价格更高，房地产开发商投资加大，政府收入增加。政府收入增加可以搞更多更好的基础建设（含政绩工程），房价更高，房地产投资更多。


{{<echarts>}}
// const colors2 = ['#5070dd', '#b6d634', '#505372'];
option = {
  color: colors2,
  tooltip: {
    trigger: 'axis',
    axisPointer: {
      type: 'cross'
    }
  },
  grid: {
    right: '20%'
  },
  toolbox: {
    feature: {
      dataView: { show: true, readOnly: false },
      restore: { show: true },
      saveAsImage: { show: true }
    }
  },
  legend: {
    data: ['邵东GDP', 'GDP增速', '固定资产投资增速']
  },
  xAxis: [
    {
      type: 'category',
      axisTick: {
        alignWithLabel: true
      },
      // prettier-ignore
      data: ['2007', '2008', '2009', '2010', '2011', '2012', '2013', '2014', '2015', '2016', '2017', '2018', '2019', '2020', '2021', '2022', '2023', '2024']
    }
  ],
  yAxis: [
    {
      type: 'value',
      name: '邵东GDP',
      position: 'left',
      alignTicks: true,
      axisLine: {
        show: true,
        lineStyle: {
          color: colors2[0]
        }
      },
      axisLabel: {
        formatter: '{value} 亿元'
      }
    },
    {
      type: 'value',
      name: 'GDP增速',
      position: 'right',
      alignTicks: true,
      axisLine: {
        show: true,
        lineStyle: {
          color: colors2[1]
        }
      },
      axisLabel: {
        formatter: '{value} %'
      }
    },
    {
      type: 'value',
      name: '固定资产投资增速',
      position: 'right',
      alignTicks: true,
      offset: 80,
      axisLine: {
        show: true,
        lineStyle: {
          color: colors2[2]
        }
      },
      axisLabel: {
        formatter: '{value} %'
      }
    }
  ],
  series: [
    {
      name: '邵东GDP',
      type: 'bar',
      yAxisIndex: 0,
      data: [
        90.87, null, 121.8, null, 202.1522, null, 254.27, 283.0484, 310.1094, 336.3720, 381.5505, 430.4487, 605.64, 616.7381, 685.210, 721.5, 763.32, 791.5
      ]
    },
    {
      name: 'GDP增速',
      type: 'line',
      yAxisIndex: 1,
      data: [
        10.3, null, 14.6, null, 14.4, null, 10.5, 10.6, 8.8, 8.2, 10.1, 11, 10, 4.3, 9.4, 5.1, 5.5, 5.5
      ]
    },
    {
      name: '固定资产投资增速',
      type: 'line',
      yAxisIndex: 2,
      data: [
        42.06, null, 32.6, null, 34.6, null, 35.0, 29.8, 21.6, 14.8, 17.1, 20.6, 16, 10.6, 10.6, 13.3, 8.1, 9.4
      ]
    }
  ]
};
{{</echarts>}}

注意：本文截止目前为止，绘制了五幅图，结合笔者对政府网站公布数据的观察，发现，凡是数据指标不好看，就不公布了，或公布不可比了，或者公布一些其他可能相关的指标（必得是增长的）。原想看看房地产投资在固定资产投资中的比重，和北京市的情况对照一下。


| 年份 | 固定资产投资（亿元） | 同比增长（%） | 房地产投资（亿元） | 同比增长 | 比重（%） |
|------------|:----------:|------------|------------|------------|------------|
| 2024 |          \-          | 9.4           | \-                 | -21.4    | \-        |
| 2023 |          \-          | 8.1           | \-                 | -38.9    | \-        |
| 2022 |          \-          | 13.3          | \-                 | -1.8     | \-        |
| 2021 |          \-          | 10.6          | \-                 | 7.7      | \-        |
| 2020 |          \-          | 10.6          | \-                 | \-       | \-        |
| 2019 |       301.0660       | 16            | \-                 | \-       | \-        |
| 2018 |       262.2639       | 20.6          | \-                 | \-       | \-        |
| 2017 |       307.8615       | 17.1          | 43.1523            | 5.13     | 14.02     |
| 2016 |       265.6025       | 14.8          | 41.0473            | 24.12    | 15.45     |
| 2015 |       267.1008       | 21.6          | 33.0699            | 42.0     | 12.38     |
| 2014 |       216.5106       | 29.8          | 23.2333            | 41.6     | 10.73     |


结合肉眼对邵东市的观察，最近几年，商品住宅楼盘如雨后春笋般拔地而起，共计 42 个新建楼盘。[农村自建房的那些琐事](/2025/02/self-built-houses)提及其中大部分重要的楼盘。


目前，各城市商品房的供给是大于需求的，房价要想保持坚挺，城市人口得继续增加（一些城市的购房政策与子女数量联系起来，生的越多，可购房数越多）。然而，结合邵东市 2001-2023 年城镇人口与城镇化率的数据来看，自 2020 年以来，城镇人口并不增加，城镇化率也已接近 60%，这在县级市已经很高了。下一步，继续提升城镇化率需要将老年人从乡村迁入城市，一些城市的新建房在老人宜居上开始下功夫。

{{<echarts>}}
// const colors2 = ['#5070dd', '#b6d634', '#505372'];
option = {
  title: {
    text: '邵东市城镇人口和城镇化率 2001-2023',
    left: 'center',
    textStyle: {
      fontSize: 20
    },
    subtextStyle: {
      color: '#175ce5',
      fontSize: 15,
      fontWeight: 'bold'
    }
  },
  color: colors2,
  tooltip: {
    trigger: 'axis',
    axisPointer: {
      type: 'cross'
    }
  },
  grid: {
    right: '20%'
  },
  toolbox: {
    feature: {
      dataView: { show: true, readOnly: false },
      restore: { show: true },
      saveAsImage: { show: true }
    }
  },
  legend: {
    data: ['城镇人口', '城镇化率']
  },
  xAxis: [
    {
      type: 'category',
      axisTick: {
        alignWithLabel: true
      },
      // prettier-ignore
      data: ['2001', '2002', '2003', '2004', '2005', '2006', '2007', '2008', '2009', '2010', '2011', '2012', '2013', '2014', '2015', '2016', '2017', '2018', '2019', '2020', '2021', '2022', '2023']
    }
  ],
  yAxis: [
    {
      type: 'value',
      name: '城镇人口',
      position: 'left',
      alignTicks: true,
      axisLine: {
        show: true,
        lineStyle: {
          color: colors2[0]
        }
      },
      axisLabel: {
        formatter: '{value} 万人'
      }
    },
    {
      type: 'value',
      name: '城镇化率',
      position: 'right',
      alignTicks: true,
      axisLine: {
        show: true,
        lineStyle: {
          color: colors2[1]
        }
      },
      axisLabel: {
        formatter: '{value} %'
      }
    }
  ],
  series: [
    {
      name: '城镇人口',
      type: 'bar',
      yAxisIndex: 0,
      data: [
        13.25, 37.07, 37.18, 37.35, 38.50, 40.16, 41.01, 42.08, 42.64, 34.99, 36.29, 38.72, 40.70, 42.99, 45.66, 47.95, 50.28, 50.91, 52.47, 59.09, 58.34, 58.45, 58.53
      ]
    },
    {
      name: '城镇化率',
      type: 'line',
      yAxisIndex: 1,
      data: [
       11.26, 31.50, 31.61, 31.62, 32.36, 33.58, 34.12,	34.88, 35.94, 39.03, 40.23, 42.45, 44.43, 46.63, 49.20, 51.31, 53.81, 55.91, 57.81, 56.85, 57.72, 58.33, 59.01
      ]
    }
  ]
};
{{</echarts>}}

数据来源：湖南省统计局发布的[湖南统计年鉴](https://tjj.hunan.gov.cn/hntj/tjfx/hntjnj/hntjnjwlb/index.html)。
