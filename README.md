# Pet Evolution App

基于 SwiftUI 的 iOS 宠物进化应用，使用 Gemini AI 生成宠物图片。

## 功能概述

三步宠物进化流程，每步都通过 AI 生成图片：

1. **配置宠物** — 选择风格、颜色、动物组合
2. **第一次进化** — 查看生成的宠物，点击进化
3. **最终进化** — 进化到最终形态
4. **完成** — 展示最终宠物，可重新开始

## 后端配置

需要在同一局域网下运行后端服务：

```bash
# 进入后端目录
npm start  # 需要 GEMINI_API_KEY 环境变量
```

后端默认地址：`http://10.0.0.131:3001`（在 `PetEvolutionService.swift` 中修改）

## 项目结构

```
PetEvolution/
├── Models.swift                  # Pet 数据模型、AnyJSON、EvolutionStage
├── PetEvolutionService.swift     # API 服务层（generate-pet、evolve-pet、health check）
├── MockPetEvolutionService.swift # 已废弃，仅保留空壳
├── PetEvolutionViewModel.swift   # 状态管理（配置、生成、进化、health）
├── Components.swift              # PetImageView（base64解码）、LoadingView、ErrorView
├── PetSelectionView.swift        # PetConfigurationView — 配置界面
├── EvolutionView.swift           # 进化界面（Stage 1 & 2）
├── CompletionView.swift          # 完成界面
└── ContentView.swift             # 主导航容器 + health check
```

## 架构

- **MVVM**：Model (`Pet`) → ViewModel (`PetEvolutionViewModel`) → View
- **API**：`PetEvolutionService` 单例，`async/await` + `URLSession`
- **图片**：`PetImageView` 解码 base64 data URL，无需 `AsyncImage`

## API 请求格式

所有字符串值首字母大写：

```json
{
  "style": "Gentle",
  "colorPalette": "Blue and Purple",
  "animals": ["Cat", "Dragon"]
}
```

详见 `API_REFERENCE.md` 和 `API_INTEGRATION.md`

## 技术栈

- SwiftUI + Swift 5.9+
- iOS 15.0+
- URLSession（multipart/form-data 上传图片）
- Gemini AI（后端）
