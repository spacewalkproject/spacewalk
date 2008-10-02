import com.redhat.satellite.search.db.DatabaseManager;
import com.redhat.satellite.search.db.WriteQuery;
import com.redhat.satellite.search.config.Configuration;

def deleteQuery(config, queryName) {
    DatabaseManager databaseManager = new DatabaseManager(config)
    WriteQuery query = null;
    try {
        query = databaseManager.getWriterQuery(queryName);
        query.delete(null);
    }
    finally {
        query.close();
    }
}

/**
  Currently, only handles Errata and Packages
  Need to add: User, System, Docs
  **/
Configuration config = new Configuration()
deleteQueries = ["deleteLastErrata", "deleteLastPackage", 
              "deleteLastServer", "deleteLastHardwareDevice", 
              "deleteLastSnapshotTag", "deleteLastServerCustomInfo"]
deleteQueries.each{deleteQuery(config, it)}

println "Database has been prepared so we can re-index."

indexWorkDir = config.getString("search.index_work_dir", null);
println "Previous indexes will be deleted on filesystem under ${indexWorkDir}"

dirs = [indexWorkDir+"/package", indexWorkDir+"/errata", 
     indexWorkDir+"/server", indexWorkDir+"/hwdevice", 
     indexWorkDir+"/snapshotTag", indexWorkDir+"/serverCustomInfo"]
dirs.each { 
    cmd = "rm -r $it"
    def proc = cmd.execute()
    proc.waitFor()
}




