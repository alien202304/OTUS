# * Galera-related settings
#
# See the examples of server wsrep.cnf files in /usr/share/mysql
# and read more at https://mariadb.com/kb/en/galera-cluster/

### mariadb-01 host ###

[galera]
# Mandatory settings
wsrep_on                 = ON
wsrep_provider           = /usr/lib/galera/libgalera_smm.so
wsrep_cluster_name       = "galera_cluster"
wsrep_cluster_address    = "gcomm://192.168.101.163,192.168.101.164,192.168.101.165"
binlog_format            = row
default_storage_engine   = InnoDB
innodb_autoinc_lock_mode = 2
wsrep_node_address       = "192.168.101.163"

# Allow server to accept connections on all interfaces.
bind-address = 0.0.0.0


### mariadb-02 host ###

[galera]
# Mandatory settings
wsrep_on                 = ON
wsrep_provider           = /usr/lib/galera/libgalera_smm.so
wsrep_cluster_name       = "galera_cluster"
wsrep_cluster_address    = "gcomm://192.168.101.163,192.168.101.164,192.168.101.165"
binlog_format            = row
default_storage_engine   = InnoDB
innodb_autoinc_lock_mode = 2
wsrep_node_address       = "192.168.101.164"

# Allow server to accept connections on all interfaces.
bind-address = 0.0.0.0


### mariadb-03 host ###

[galera]
# Mandatory settings
wsrep_on                 = ON
wsrep_provider           = /usr/lib/galera/libgalera_smm.so
wsrep_cluster_name       = "galera_cluster"
wsrep_cluster_address    = "gcomm://192.168.101.163,192.168.101.164,192.168.101.165"
binlog_format            = row
default_storage_engine   = InnoDB
innodb_autoinc_lock_mode = 2
wsrep_node_address       = "192.168.101.165"

# Allow server to accept connections on all interfaces.
bind-address = 0.0.0.0