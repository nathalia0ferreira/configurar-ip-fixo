# Guia de Contribuição

Este projeto segue a especificação **[Conventional Commits v1.0.0](https://www.conventionalcommits.org/en/v1.0.0/)**
para as mensagens de commit. O objetivo é manter o histórico do Git legível,
permitindo que qualquer pessoa entenda rapidamente o que mudou e por quê, sem
precisar abrir o diff.

## Estrutura da mensagem

```
<tipo>[escopo opcional][!]: <descrição>

[corpo opcional]

[rodapés opcionais]
```

- **tipo**: categoria da mudança (lista abaixo).
- **escopo**: parte do projeto afetada, entre parênteses (lista abaixo).
- **!**: adicione antes do `:` quando a mudança quebra compatibilidade.
- **descrição**: resumo direto, no infinitivo/imperativo, em português, sem
  ponto final. Ex.: `corrige validação de IP vazio`, não `correção` ou
  `corrigido`.

## Tipos utilizados

| Tipo       | Quando usar                                                                 |
|------------|------------------------------------------------------------------------------|
| `feat`     | Adiciona uma funcionalidade nova (ex.: um passo novo no assistente)        |
| `fix`       | Corrige um comportamento incorreto ou bug                                  |
| `refactor` | Reorganiza/melhora o código sem mudar o comportamento esperado             |
| `perf`     | Melhora desempenho (ex.: reduz chamadas ao PowerShell)                     |
| `docs`     | Alterações no README, neste guia, comentários de documentação, LICENSE     |
| `test`     | Adiciona ou ajusta testes/roteiros manuais de verificação                  |
| `style`    | Formatação, indentação, nomes de variável — sem mudar a lógica             |
| `build`    | Empacotamento, estrutura de distribuição do `.bat`                         |
| `ci`       | Pipelines e automações (GitHub Actions, hooks de validação)                |
| `chore`    | Manutenção que não se encaixa melhor em outro tipo (ex.: `.gitignore`)     |
| `revert`   | Reverte um commit anterior                                                 |

Escolha pelo efeito real da mudança, não pela conveniência: um ajuste visual
que corrige um defeito funcional é `fix`; uma reorganização interna sem
mudança de comportamento é `refactor`.

## Escopos utilizados

O projeto é hoje um único script (`configurar-ip-fixo.bat`), organizado em
passos bem definidos. Os escopos abaixo refletem essa estrutura real — não
crie escopos novos sem necessidade:

| Escopo       | Parte do projeto                                                         |
|--------------|----------------------------------------------------------------------------|
| `admin`      | Verificação de execução como administrador                                |
| `conexao`    | Passo 1 — listagem e escolha do adaptador de rede                          |
| `ip`         | Passo 2 — IP fixo, máscara e gateway principais                            |
| `dns`        | Passo 3 — DNS primário e secundário                                       |
| `secundarios`| Passo 4 — IPs secundários (ex.: catracas/leitores em outra faixa de rede)  |
| `resumo`     | Tela de resumo e confirmação antes de aplicar                              |
| `aplicar`    | Execução dos comandos `netsh` e o retorno automático para DHCP em falha   |
| `validacao`  | Função `validaIP` e outras validações de entrada                          |
| `script`     | Mudanças estruturais que afetam o `.bat` como um todo (cores, cabeçalho)   |
| `readme`     | `README.md`                                                                |
| `contributing` | Este guia (`CONTRIBUTING.md`)                                           |
| `license`    | `LICENSE`                                                                  |
| `hooks`      | Hooks de Git do próprio repositório                                       |

Use o escopo quando ele deixar a mensagem mais clara. Em uma mudança que
afeta o arquivo inteiro (ex.: indentação geral), pode-se omitir o escopo.

## Mudanças que quebram compatibilidade

Use `!` depois do tipo/escopo, ou o rodapé `BREAKING CHANGE:`, **apenas**
quando algo que já funcionava deixa de funcionar da mesma forma — por
exemplo, se um parâmetro de linha de comando mudar de nome ou se o formato
do resumo exibido mudar de forma incompatível com scripts que o leem.

```
feat(secundarios)!: exige mascara obrigatoria para cada IP extra

BREAKING CHANGE: execuções automatizadas que não informavam a mascara
e dependiam do valor padrão agora precisam passá-la explicitamente.
```

Não marque como breaking change um ajuste que não quebra nada.

## Exemplos reais para este projeto

```
feat(secundarios): permite remover um IP da lista antes de aplicar
fix(aplicar): restaura DHCP também quando a adição do IP secundário falha
fix(conexao): evita erro quando nenhum adaptador está conectado
refactor(validacao): extrai verificação de IP duplicado para função própria
docs(readme): explica como cancelar o assistente sem aplicar mudanças
chore(license): atualiza o ano de copyright
ci(hooks): adiciona validação automática do formato da mensagem de commit
```

## Commits pequenos e coerentes

Separe em commits diferentes mudanças independentes (uma funcionalidade nova
e uma correção não relacionada, por exemplo). Mantenha juntas apenas as
mudanças que não fazem sentido isoladas, como uma função nova e o ponto do
script que passa a chamá-la.

## Validação local (opcional, recomendada)

O repositório inclui um hook de `commit-msg` em `.githooks/` que avisa
quando uma mensagem não segue o padrão. Para ativá-lo localmente:

```bash
git config core.hooksPath .githooks
```

(No Windows, rode esse comando no Git Bash ou no terminal que você usa para
os comandos `git` deste repositório.)

Você também pode usar o modelo de mensagem incluso, que abre com a estrutura
já comentada ao rodar `git commit` sem `-m`:

```bash
git config commit.template .gitmessage
```
