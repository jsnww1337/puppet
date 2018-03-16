file { '/tmp/hellojohnnyboy.txt':
	ensure => file,
	content => "hello, Johny boy!",
}
