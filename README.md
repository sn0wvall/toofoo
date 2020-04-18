# toofoo

A simple calendar app for scheduling and viewing tasks in your terminal

	toofoo [show|new|del]

## show|print

* Parameters: [today|tomorrow|yesterday|date]
* Shows events on the specified day
* e.g. toofoo show date 30/12/20
  
## new|add
* Parameters: n/a
* Queries user for new event and date
* Date formats are those listed in date(1): e.g. 5 March 2019, 5/7/19
                  
## del|rm
* parameters: n/a
* Queries user for event to delete

## Configuration Files

Configuration Files are searched for in 

* $XDG\_CONFIG\_HOME/toofoo/config
* $HOME/.config/toofoo/config
* $HOME/.toofoorc
* $HOME/.toofoo/config"
