/**
 * 
 */
 import com.redhat.satellite.search.config.Configuration
 import com.redhat.satellite.search.db.DatabaseManager;
 import com.redhat.satellite.search.db.Query;
 import com.redhat.satellite.search.scheduler.tasks.IndexErrataTask;
 import com.redhat.satellite.search.db.models.Errata;
 
 import java.util.List;
 
/**
 * @author jmatthews
 *
 */
public class ShowErrata{

	protected Configuration config = null;
	protected DatabaseManager dbMgr = null;
	protected IndexErrataTask indexErrata = null;
	
	public void init() {
		config = new Configuration();
		dbMgr = new DatabaseManager(config);
		indexErrata = new IndexErrataTask();
	}
	
	public void printUnindexedErrata() {
		List<Errata> errata = indexErrata.getErrata(dbMgr);
		errata.each { println "Errata: $it"};
	}
	
	public void printAll() {
	    Query<Errata> errataQuery = dbMgr.getQuery("getAllErrata");
	    List<Errata> retval = null;
	    try {
            retval = errataQuery.loadList();
        }
        finally {
            errataQuery.close();
        }
        retval.each{ println "Errata: $it" };
	}

	/**
	 * @param args
	 */
	public static void main(def args){
	    ShowErrata se = new ShowErrata();
	    se.init();
	    se.printAll();
	}
	
}
