# A-system-for-Blog
NKU China 2024-2025spring Database System Project！

# 程序运行说明
首先你需要一个版本为3.12.0的python环境。请自行安装Mysql8.4.4。

在数据库中导入文件目录下的blog_str.sql文件。

其次，请安装本项目下requirements文件内的库，保证项目运行支持正常。

随后，运行指令：

```python

python -u "e:\PostIdea\app.py"

```

打开网址 http://127.0.0.1:5000 即可体验项目！

# 文件结构说明

static文件夹：静态资源，其中avatars是头像资源，css则为空文件夹（本来有东西的，后来和html合并了）。

template：html网页文件，支撑着前端页面。

app.py:后端文件，支撑着运行逻辑。

blog_str.sql 数据库文件，可以用于导入数据库信息。

im.py hash加密文件，用于管理员手动insert账号后的加密，一般用不到，用的时候注意限制加密数据的范围。

requirements.txt：项目的python库信息。

# 南开大学2023级计算机学院 数据库系统 工程专业
# Author：2310986 陈兴浩
# Final Date：2025/6/2