from shiny.express import input, render, ui
from shinywidgets import render_plotly

import plotly.express as px
iris = px.data.iris().drop("species_id", axis = 1)

ui.page_opts(title="鸢尾花", fillable=True)

with ui.sidebar():
    ui.input_selectize(
        id = "var1", label = "选择横坐标",
        choices = ["sepal_width", "sepal_length", "petal_length", "petal_width"],
        selected = "sepal_width"
    )
    ui.input_selectize(
        id = "var2", label = "选择纵坐标",
        choices = ["sepal_width", "sepal_length", "petal_length", "petal_width"],
        selected = "sepal_length"
    )
    ui.input_selectize(
        id = "theme", label = "绘图主题",
        choices = ["ggplot2", "seaborn", "simple_white", "plotly", "plotly_white",
        "plotly_dark", "presentation", "xgridoff", "ygridoff", "gridon", "none"],
        selected = "simple_white"
    )


with ui.layout_columns(col_widths=[6, 6]):

    with ui.card(full_screen=True):
        ui.card_header("鸢尾花数据")
        @render_plotly
        def hist():
            p = px.scatter(
                iris, 
                x=input.var1(), 
                y=input.var2(), 
                color="species",
                template=input.theme(),
                title="Edgar Anderson 的鸢尾花数据",
                color_discrete_sequence=px.colors.qualitative.Set2,
              )
            p.update_layout(
                autosize=False,
                # 图形的宽高
                width=700, height=500,
                # 下左上右变空
                margin=dict(b=20, l=30, t=40, r=30),
                # 绘图区域的背景色
                paper_bgcolor="LightSteelBlue",
              )
            return p

    with ui.card(full_screen=True):
        ui.card_header("鸢尾花数据")
        @render.data_frame
        def table():
            return render.DataGrid(iris)
