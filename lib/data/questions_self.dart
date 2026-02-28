// Question data model for self-check checklist (我出轨路径)

class SelfCheckItem {
  final int id;
  final String category;
  final String title;
  final List<String> points;
  final String? tip;

  const SelfCheckItem({
    required this.id,
    required this.category,
    required this.title,
    required this.points,
    this.tip,
  });
}

const List<SelfCheckItem> kSelfCheckQuestions = [
  SelfCheckItem(
    id: 1,
    category: '消费与记录清理',
    title: '是否检查过微信或支付宝账单记录',
    points: ['是否存在敏感消费记录', '是否有异常转账对象', '时间是否可能被注意到', '如存在记录，是否已经处理'],
  ),
  SelfCheckItem(
    id: 2,
    category: '消费与记录清理',
    title: '是否清理过完整账单历史',
    points: ['月度账单', '历史记录', '邮件账单'],
    tip: '不要只删除最近几条，整体连贯性更重要',
  ),
  SelfCheckItem(
    id: 3,
    category: '消费与记录清理',
    title: '是否检查过电商或外卖收货地址',
    points: ['是否存在陌生地址', '是否有临时地址残留'],
    tip: '很多人会忘记临时修改的默认地址',
  ),
  SelfCheckItem(
    id: 4,
    category: '消费与记录清理',
    title: '是否检查过购物记录中的特殊商品',
    points: ['礼物', '私人物品', '异常购买内容', '时间节点是否合理'],
  ),
  SelfCheckItem(
    id: 5,
    category: '行程与位置痕迹',
    title: '是否查看过导航或地图历史',
    points: ['是否存在敏感地点', '是否留下足迹记录'],
  ),
  SelfCheckItem(
    id: 6,
    category: '行程与位置痕迹',
    title: '是否检查过打车或出行记录',
    points: ['行程终点', '时间节点', '是否存在异常记录'],
    tip: '删除订单不代表后台系统没有留存轨迹',
  ),
  SelfCheckItem(
    id: 7,
    category: '行程与位置痕迹',
    title: '是否核对过时间线',
    points: ['行程是否自洽', '是否存在无法解释的时间'],
  ),
  SelfCheckItem(
    id: 8,
    category: '行程与位置痕迹',
    title: '是否查看过 WiFi 连接记录',
    points: ['酒店', '宾馆', '私人场所'],
    tip: '自动连接记录常被作为关键证据',
  ),
  SelfCheckItem(
    id: 9,
    category: '应用与设备痕迹',
    title: '是否检查过应用下载记录',
    points: ['已删除软件', '下载时间', '不熟悉应用'],
  ),
  SelfCheckItem(
    id: 10,
    category: '应用与设备痕迹',
    title: '是否确认没有分身或隐藏空间残留',
    points: ['应用分身', '双系统', '隐藏入口'],
  ),
  SelfCheckItem(
    id: 11,
    category: '应用与设备痕迹',
    title: '是否查看过屏幕使用时间',
    points: ['深夜使用记录', '高频应用'],
    tip: '柱状图的异常波动非常显眼',
  ),
  SelfCheckItem(
    id: 12,
    category: '应用与设备痕迹',
    title: '是否检查过照片时间与位置',
    points: ['拍摄信息', '位置信息'],
  ),
  SelfCheckItem(
    id: 13,
    category: '应用与设备痕迹',
    title: '是否清理过隐藏相册或已删除照片',
    points: ['最近删除', '私密相册'],
  ),
  SelfCheckItem(
    id: 14,
    category: '应用与设备痕迹',
    title: '是否确认没有异常存储内容',
    points: ['私密文件', '异常空间占用'],
  ),
  SelfCheckItem(
    id: 15,
    category: '社交与聊天风险',
    title: '是否检查过最近聊天列表',
    points: ['高频联系人', '是否存在风险对象'],
  ),
  SelfCheckItem(
    id: 16,
    category: '社交与聊天风险',
    title: '是否搜索过关键词或特殊表情',
    points: ['名字/缩写', '表情符号', '特定语气词'],
    tip: '全局搜索功能往往能翻出深埋的记录',
  ),
  SelfCheckItem(
    id: 17,
    category: '社交与聊天风险',
    title: '是否确认没有小号或备用账号风险',
    points: ['账号切换状态', '登录记录'],
  ),
  SelfCheckItem(
    id: 18,
    category: '社交与聊天风险',
    title: '是否检查过聊天记录断层',
    points: ['删除是否彻底', '时间是否连续'],
  ),
  SelfCheckItem(
    id: 19,
    category: '社交与聊天风险',
    title: '是否查看过小程序或隐藏入口',
    points: ['常用小程序记录', '历史入口'],
  ),
  SelfCheckItem(
    id: 20,
    category: '社交与聊天风险',
    title: '是否检查过朋友圈或互动记录',
    points: ['点赞痕迹', '评论内容', '互动时间点'],
  ),
  SelfCheckItem(
    id: 21,
    category: '短视频与社交平台',
    title: '是否检查过钱包或消费记录',
    points: ['打赏记录', '消费购买内容'],
  ),
  SelfCheckItem(
    id: 22,
    category: '短视频与社交平台',
    title: '是否查看过聊天或互动列表',
    points: ['最近互动对象', '粉丝私信'],
  ),
  SelfCheckItem(
    id: 23,
    category: '自我确认',
    title: '是否确认所有时间节点可以自洽',
    points: ['能否逻辑解释', '逻辑是否存在漏洞'],
  ),
  SelfCheckItem(
    id: 24,
    category: '自我确认',
    title: '是否确认没有明显异常行为变化',
    points: ['突然改变习惯', '情绪异常波动'],
  ),
];
