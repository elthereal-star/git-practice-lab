# git-practice-lab

Git 分支协作练习仓库（极简版），模拟真实后端团队的分支工作流。

## 分支模型（Git Flow 简化版）

| 分支 | 用途 | 从哪里切出 | 合并回哪里 |
| --- | --- | --- | --- |
| `main` | 生产分支，永远保持可发布状态 | - | - |
| `develop` | 开发集成分支，日常功能的汇合点 | `main` | `main`（通过 release） |
| `feature/*` | 新功能开发 | `develop` | `develop` |
| `bugfix/*` | 普通 bug 修复 | `develop` | `develop` |
| `release/*` | 发版准备（冻结功能，只修 bug） | `develop` | `main` + `develop` |
| `hotfix/*` | 线上紧急修复 | `main` | `main` + `develop` |

## 本仓库预置的练习分支

- `feature/user-login`：模拟"用户登录"功能开发
- `feature/order-export`：模拟"订单导出"功能开发
- `feature/greeting-style`：与 `develop` 存在**故意制造的冲突**，用于练习冲突解决
- `bugfix/pagination-error`：模拟普通 bug 修复
- `hotfix/fix-null-pointer`：模拟线上紧急修复（从 main 切出）
- `release/v1.0.0`：模拟发版准备

## 建议练习顺序

1. clone 仓库，在 IDEA 中打开
2. 基于 `develop` 新建自己的 `feature/xxx` 分支，提交并推送
3. 把 `feature/greeting-style` 合并进 `develop`，练习解决冲突
4. 练习把 `hotfix/fix-null-pointer` 同时合并回 `main` 和 `develop`
