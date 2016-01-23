# git-trello
A gem for Git hooks.

#Instructions

    $gem install git-trello
    Successfully installed git-trello-0.0.1
    1 gem installed
    $ cat /path/to/my/repo.git/hooks/post-receive
    #!/usr/bin/ruby
    require 'git-trello'
    GitHook.new(
        :api_key => 'API_KEY',
        :oauth_token => 'OAUTH_TOKEN',
        :board_id => 'TRELLO_BOARD_ID',
        :list_id_in_progress => 'LIST_ID_IN_PROGRESS',
        :list_id_done => 'LIST_ID_IN_DONE',
        :commit_url_prefix => 'https://github.com/zmilojko/git-trello/commits/' 
    ).post_receive

###`API_KEY`
https://trello.com/1/appKey/generate

###`OAUTH_TOKEN`
This is not so well explained in Trello, but I understood that you need to authorize the app with API_KEY to access each board separatelly. To do that:

https://trello.com/1/authorize?response_type=token&name=[BOARD+NAME+AS+SHOWN+IN+URL]&scope=read,write&expiration=never&key=[YOUR+API_KEY+HERE]

where [YOUR+API_KEY+HERE] is the one you entered in the previous step, while [BOARD+NAME+AS...] is, well, what it says. If your board is 

https://trello.com/board/git-trello/5104d726d973fb4356000c5f

then you should type in "git-trello".


###`TRELLO_BOARD_ID`
It is the end of the URL when viewing the board. For example, for https://trello.com/board/git-trello/5104d726d973fb4356000c5f, board_id is 5104d726d973fb4356000c5f.

###`LIST_ID_IN_PROGRESS and LIST_ID_IN_DONE`
List IDs seem to be a (board id + list index), where all are treated as hex numbers. However, this is undocumented.

Safe way to find a list ID is to open a card from the list, click the More link in the bottom-right corner, select Export JSON and find the idList.

Post receive will move all referenced cards to the LIST_ID_IN_PROGRESS, unless they are referenced by Close or Fix word, in which case it will move them to the LIST_ID_IN_DONE.

###`commit_url_prefix`
If you have a web view of your Git repo (such as GitLab), you can enter the URL which, when sufixed with the commit SHA will show the commit in question. Post-receive will add a link to the commit to each of the comments on cards.

Another example could be https://github.com/zanker/github-trello/commit/.

If you ommit the parameter, link will not be placed.

#Credits

Many thanks to Zachary Anker for the trello/github integration.

