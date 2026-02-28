// Question data model for partner trace checklist (TA出轨路径)

class QuestionItem {
  final int id;
  final String category;
  final String title;
  final String? subtitle;
  final List<String> points;
  final String? tip;

  const QuestionItem({
    required this.id,
    required this.category,
    required this.title,
    this.subtitle,
    required this.points,
    this.tip,
  });
}

const List<QuestionItem> kQuestions = [
  // 一、消费与地址痕迹
  QuestionItem(
    id: 1,
    category: '消费与地址痕迹',
    title: '查看微信或支付宝账单记录',
    subtitle: '重点确认',
    points: ['是否存在酒店或住宿消费', '是否出现陌生转账对象', '是否有你不了解的餐饮或娱乐支出'],
    tip: '时间节点尤其重要。',
  ),
  QuestionItem(
    id: 2,
    category: '消费与地址痕迹',
    title: '导出完整账单',
    subtitle: '不要只看最近，查看：',
    points: ['月度账单', '全部历史记录', '邮件账单'],
    tip: '很多人只清理表面记录。',
  ),
  QuestionItem(
    id: 3,
    category: '消费与地址痕迹',
    title: '收货地址管理',
    subtitle: '打开美团/淘宝/京东，重点确认：',
    points: ['是否存在陌生收货地址', '是否出现你不知道的地点', '是否有临时或异常地址'],
    tip: '很多人删除订单，但会忘记删除地址。',
  ),
  QuestionItem(
    id: 4,
    category: '消费与地址痕迹',
    title: '查看购物记录中的特殊商品',
    subtitle: '确认是否存在：',
    points: ['礼物类商品', '私人物品', '你从未见过的购买内容'],
    tip: '尤其注意时间节点。',
  ),

  // 二、行程与位置痕迹
  QuestionItem(
    id: 5,
    category: '行程与位置痕迹',
    title: '查看地图足迹或导航历史',
    subtitle: '重点确认：',
    points: ['酒店附近', '私人会所', '陌生小区', '非常用地点'],
    tip: '不要只看最近记录，历史轨迹更重要。',
  ),
  QuestionItem(
    id: 6,
    category: '行程与位置痕迹',
    title: '查看打车或出行软件记录',
    subtitle: '确认：',
    points: ['行程终点', '时间节点', '与实际描述是否一致'],
    tip: '删除订单不代表没有记录。',
  ),
  QuestionItem(
    id: 7,
    category: '行程与位置痕迹',
    title: '核对时间线',
    subtitle: '把他说的行程与实际记录对比：',
    points: ['是否存在空白时间', '是否前后说法不一致'],
  ),
  QuestionItem(
    id: 8,
    category: '行程与位置痕迹',
    title: '查看手机 WiFi 连接历史',
    subtitle: '进入 WiFi 设置记录，重点关注：',
    points: ['酒店名称', '宾馆', '私人影院', '陌生热点'],
    tip: '很多人不会清理这里。',
  ),

  // 三、应用与设备痕迹
  QuestionItem(
    id: 9,
    category: '应用与设备痕迹',
    title: '查看 App Store 下载历史',
    subtitle: '头像 → 已购项目，确认：',
    points: ['已删除的软件', '下载时间节点', '不熟悉的应用'],
    tip: '云端下载图标仍会保留。',
  ),
  QuestionItem(
    id: 10,
    category: '应用与设备痕迹',
    title: '是否存在分身或双系统',
    subtitle: '确认：',
    points: ['应用分身', '双空间', '隐藏系统'],
    tip: '很多隐私行为会在这里。',
  ),
  QuestionItem(
    id: 11,
    category: '应用与设备痕迹',
    title: '查看屏幕使用时间',
    subtitle: '重点关注：',
    points: ['深夜活跃时间', '高频应用'],
    tip: '异常时段通常会留下痕迹。',
  ),
  QuestionItem(
    id: 12,
    category: '应用与设备痕迹',
    title: '查看照片时间与位置',
    subtitle: '确认：',
    points: ['拍摄时间', '位置信息', '是否存在异常照片'],
  ),
  QuestionItem(
    id: 13,
    category: '应用与设备痕迹',
    title: '查看隐藏相册或已删除照片',
    subtitle: '检查相簿底部',
    points: ['最近删除', '隐藏项目'],
    tip: '很多内容会被放在这里。',
  ),
  QuestionItem(
    id: 14,
    category: '应用与设备痕迹',
    title: '检查手机存储空间',
    subtitle: '异常占用可能意味着：',
    points: ['隐藏内容', '私密文件'],
  ),

  // 四、社交与聊天痕迹
  QuestionItem(
    id: 15,
    category: '社交与聊天痕迹',
    title: '查看最近聊天列表',
    subtitle: '确认：',
    points: ['聊天最频繁的人', '是否出现陌生联系人'],
  ),
  QuestionItem(
    id: 16,
    category: '社交与聊天痕迹',
    title: '搜索聊天关键词',
    subtitle: '搜索你的名字/外号，确认：',
    points: ['他在别人面前如何提及你'],
  ),
  QuestionItem(
    id: 17,
    category: '社交与聊天痕迹',
    title: '搜索特殊表情或暗号',
    subtitle: '例如 🐔 🍑 ❤️ 💋',
    points: ['很多隐晦沟通会使用表情'],
  ),
  QuestionItem(
    id: 18,
    category: '社交与聊天痕迹',
    title: '查看好友添加记录',
    subtitle: '确认：',
    points: ['最近新增好友', '添加方式来源'],
  ),
  QuestionItem(
    id: 19,
    category: '社交与聊天痕迹',
    title: '是否存在小号或备用账号',
    subtitle: '进入账号切换页面确认：',
    points: ['是否存在第二账号', '是否存在异常登录'],
    tip: '很多人会用小号当储存空间。',
  ),
  QuestionItem(
    id: 20,
    category: '社交与聊天痕迹',
    title: '查看聊天记录是否存在断层',
    subtitle: '确认：',
    points: ['时间突然缺失', '记录异常减少'],
    tip: '这通常意味着清理行为。',
  ),
  QuestionItem(
    id: 21,
    category: '社交与聊天痕迹',
    title: '查看小程序或隐藏入口',
    subtitle: '确认：',
    points: ['常用小程序', '不熟悉的小程序'],
  ),
  QuestionItem(
    id: 22,
    category: '社交与聊天痕迹',
    title: '查看群聊列表',
    subtitle: '确认：',
    points: ['是否存在陌生群', '是否加入特殊社交群体'],
  ),
  QuestionItem(
    id: 23,
    category: '社交与聊天痕迹',
    title: '查看朋友圈互动记录',
    subtitle: '进入互动列表确认：',
    points: ['最近点赞对象', '评论对象'],
    tip: '互动频率往往比聊天更真实。',
  ),

  // 五、短视频与社交平台痕迹
  QuestionItem(
    id: 24,
    category: '短视频与社交平台痕迹',
    title: '查看短视频平台钱包记录',
    subtitle: '确认：',
    points: ['打赏记录', '消费记录'],
  ),
  QuestionItem(
    id: 25,
    category: '短视频与社交平台痕迹',
    title: '查看短视频分享列表头像',
    subtitle: '分享面板底部头像通常代表：',
    points: ['最近联系最频繁的人'],
  ),
  QuestionItem(
    id: 26,
    category: '短视频与社交平台痕迹',
    title: '查看私信或聊天功能',
    subtitle: '即使删除记录：',
    points: ['互动痕迹仍可能存在'],
  ),

  // 六、行为变化与异常
  QuestionItem(
    id: 27,
    category: '行为变化与异常',
    title: '是否突然更换密码或加强隐私',
    subtitle: '例如：',
    points: ['手机不离身', '不愿让你看到屏幕'],
  ),
  QuestionItem(
    id: 28,
    category: '行为变化与异常',
    title: '是否出现解释反复变化',
    subtitle: '特征：',
    points: ['前后说法不一致'],
  ),
  QuestionItem(
    id: 29,
    category: '行为变化与异常',
    title: '是否刻意回避某些问题',
    subtitle: '例如：',
    points: ['转移话题', '情绪防御'],
  ),
  QuestionItem(
    id: 30,
    category: '行为变化与异常',
    title: '是否存在你无法解释的行为变化',
    subtitle: '例如：',
    points: ['突然改变习惯', '时间异常'],
  ),
];
