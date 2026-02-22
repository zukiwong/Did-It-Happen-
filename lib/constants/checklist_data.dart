import '../models/checklist_item.dart';

const List<ChecklistItem> kChecklistItems = [
  // ── 阶段1：关系信号（列表勾选）────────────────────────
  ChecklistItem(id: 'c1', phase: 1, category: '沟通', question: '最近沟通频率是否明显下降？'),
  ChecklistItem(id: 'c2', phase: 1, category: '沟通', question: '回复消息是否比以前明显变慢？'),
  ChecklistItem(id: 'c3', phase: 1, category: '沟通', question: '对话内容是否变得更简短、更表面？'),
  ChecklistItem(id: 'c4', phase: 1, category: '情绪', question: '对方情绪是否变得更容易波动？'),
  ChecklistItem(id: 'c5', phase: 1, category: '情绪', question: '对方是否对你变得更容易不耐烦或暴躁？'),
  ChecklistItem(id: 'c6', phase: 1, category: '情绪', question: '对方是否经常显得心不在焉或情绪不在线？'),
  ChecklistItem(id: 'c7', phase: 1, category: '手机', question: '对方是否比以前更在意手机隐私？'),
  ChecklistItem(id: 'c8', phase: 1, category: '手机', question: '对方是否会避开你接听电话或回复消息？'),

  // ── 阶段2：行为验证（一题一页）────────────────────────
  ChecklistItem(
    id: 'b1',
    phase: 2,
    category: '行程',
    question: '最近是否存在行程不透明的时间段？',
    detail: '例如无法解释的时间空白、临时变动却没有合理说明。',
  ),
  ChecklistItem(
    id: 'b2',
    phase: 2,
    category: '行程',
    question: '是否开始更频繁地加班或出差？',
    detail: '请判断这是否是最近新出现的规律，而非一直以来如此。',
  ),
  ChecklistItem(
    id: 'b3',
    phase: 2,
    category: '生活',
    question: '是否注意到对方外貌或打扮习惯发生变化？',
    detail: '例如购置新衣物、出门前更注重形象等。',
  ),
  ChecklistItem(
    id: 'b4',
    phase: 2,
    category: '生活',
    question: '对方是否突然出现了你不了解来源的新喜好或口头禅？',
    detail: '例如新的音乐偏好、去过陌生的地方、使用你从未听过的词。',
  ),
  ChecklistItem(
    id: 'b5',
    phase: 2,
    category: '数字',
    question: '对方是否更换了密码或增加了设备隐私设置？',
    detail: '尤其是近期才出现的变化，且没有给出明确理由。',
  ),

  // ── 阶段3：价值观深度（一题一页）────────────────────────
  ChecklistItem(
    id: 'v1',
    phase: 3,
    category: '价值观',
    question: '你们对于异性社交的界限是否一致？',
    detail: '对这个边界的认知不同，往往是很多无声冲突的根源。',
  ),
  ChecklistItem(
    id: 'v2',
    phase: 3,
    category: '价值观',
    question: '是否存在你认为越界、但对方认为正常的行为？',
    detail: '例如用"只是朋友"来合理化你觉得不对的事。',
  ),
  ChecklistItem(
    id: 'v3',
    phase: 3,
    category: '价值观',
    question: '是否出现过对方隐瞒某事、事后又将其合理化的情况？',
    detail: '隐瞒+合理化的模式，比单次行为本身更值得关注。',
  ),
];
