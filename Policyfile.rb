name 'hello_world'

default_source :supermarket

cookbook 'hello_world'

run_list 'recipe[hello_world::default]'
