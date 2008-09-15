use ExtUtils::MakeMaker;
use Config;
%config = (
           'linux' => [ '-D_LINUX_ -D_ETH_ -D_IFLIST_'.$ENV{'CFLAGS'},
	              'RawIP.o util.o eth.o ifaddrlist.o',
		      '',
           q{$def .= ' -D_GLIBC_' if -e "/usr/include/net/if_packet.h"}, 
		      ],
		      
	   'solaris' => [ '-D_SOLARIS_ -D_IFLIST_',
	                  'RawIP.o util.o ifaddrlist.o',
         "Sorry,ethernet related methods are not implemented on Solaris
Sorry, the rdev function is not imlemented on Solaris\n",
	                  '',		  
			],
			
	   'freebsd' => [ '-D_BSDRAW_ -D_ETH_ -D_BPF_ -D_IFLIST_ \
                         -DHAVE_SOCKADDR_SA_LEN',
			  'RawIP.o util.o ifaddrlist.o eth.o rdev.o',
			  '',
			  '',
			],
			  
	   'netbsd' => [ '-D_BSDRAW_ -D_ETH_ -D_BPF_ -D_IFLIST_ \
	                  -DHAVE_SOCKADDR_SA_LEN',
			  'RawIP.o util.o ifaddrlist.o eth.o rdev.o',
			  '',
			  '',
			],
	                
	   'bsdos' => [ '-D_BSDRAW_ -D_ETH_ -D_BPF_ -D_IFLIST_ \
	                  -DHAVE_SOCKADDR_SA_LEN',
			  'RawIP.o util.o ifaddrlist.o eth.o rdev.o',
			  '',
			  '',
			],

	   'openbsd' => ['-D_ETH_ -D_BPF_ -D_IFLIST_ -DHAVE_SOCKADDR_SA_LEN',
                         'RawIP.o util.o ifaddrlist.o eth.o rdev.o',
			  '',
q|$def .= ' -D_BSDRAW_' if join('',(split /\./,$Config{osvers})[0,1]) < 21|, 
			],
	  
	   'others'   => ['',
	                  'RawIP.o util.o',
     "Sorry,ethernet related methods are not implemented on this system 
Sorry, the ifaddrlist function is not imlemented on this system
Sorry, the rdev function is not imlemented on this system\n",
                          '',
			 ]
         );			 

$name = 'others' unless exists $config{$name = $Config{osname}}; 
$def = $config{$name}->[0];
$obj = $config{$name}->[1];
print $config{$name}->[2];
eval $config{$name}->[3];

WriteMakefile(
    'NAME'	=> 'Net::RawIP',
    'VERSION_FROM' => 'RawIP.pm', 
    'LIBS'	=> ['-lpcap'],   
    'DEFINE'	=> $def,      
    'INC'	=> '-I/usr/include/pcap',      
    'OBJECT' => $obj
);

