# Configurar IP Fixo

Assistente de linha de comando para Windows que configura **IP fixo** em uma
conexão de rede, com a opção de adicionar **IPs secundários** para comunicar
com equipamentos em outras faixas de rede (como catracas e leitores de
controle de acesso).

Criado para o dia a dia de suporte técnico: transforma uma configuração que
exigia vários comandos `netsh` e abrir as propriedades de rede em um passo a
passo guiado, com validação e volta automática para DHCP se algo der errado.

## Como funciona

O script conduz a configuração em 4 passos e só aplica depois de uma confirmação:

1. **Conexão de rede** — lista os adaptadores do computador (via PowerShell) e
   mostra quais estão conectados.
2. **IP fixo** — lê o IP, a máscara e o gateway atuais e sugere esses valores
   como ponto de partida.
3. **DNS** — primário e secundário.
4. **IPs secundários** — adiciona um ou mais IPs extras (até 10), um para cada
   rede com a qual o computador precisa se comunicar.

Antes de aplicar, exibe um **resumo** com todas as opções:
**Aplicar**, **Voltar e corrigir** ou **Cancelar**.

## Recursos

- Verifica se está sendo executado **como administrador** e explica como fazer, se não estiver.
- **Valida** cada endereço IP digitado antes de seguir.
- Calcula a máscara a partir da configuração atual do adaptador.
- Aplica tudo com `netsh` e, **se qualquer etapa falhar, devolve a conexão para
  DHCP**, evitando deixar o computador sem rede.
- Interface colorida no terminal, com mensagens em português.

## Como usar

1. Baixe o arquivo `configurar-ip-fixo.bat`.
2. Clique com o botão direito e escolha **Executar como administrador**.
3. Siga os passos na tela.

> Requer Windows 10 ou superior (usa `netsh` e cmdlets de rede do PowerShell).

## Tecnologias

`Batch (cmd)` · `PowerShell` · `netsh`

## Licença

[MIT](LICENSE)
