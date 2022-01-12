# Bureau ZSH prompt

Just a prompt for ZSH. The right prompt is asynchronous, so it work fine even on large repositories.

It is reincarnation of [my bureau theme for oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh/wiki/themes#bureau). I created it when I stopped using oh-my-zsh.

<img alt="bureau zsh prompt" 
src="https://user-images.githubusercontent.com/529247/149222635-61d1e2ad-5f0e-4a20-82c7-60a7971af528.png">

It shows on the left:

 * user name,
 * host name,
 * current path.

On the right:

 * current time,
 * current git branch (called test on screenshot),
 * staged and unstaged files (green and red bullets),
 * current action (rebase or merge).

# Usage

Add following string to your `.zshrc`:

```
source /path/to/prompt_bureau_setup.zsh [color1] [color2] [color3]
```

Colors are optional. If you pass only one color, it will be used for username,
hostname and current branch. If you pass two colors, the first will be used for
username and branch, and the second for hostname. If you pass three colors, it
will be used for username, hostname and branch accordingly.
