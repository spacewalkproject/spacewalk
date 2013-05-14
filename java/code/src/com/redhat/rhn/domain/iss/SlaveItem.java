package com.redhat.rhn.domain.iss;

import com.redhat.rhn.frontend.dto.BaseDto;

/**
 * @author ggainey
 *
 */
public class SlaveItem extends BaseDto {
	private Long id;
	private String fqdn;
	private String ip;
	private Boolean enabled;
	private Boolean allOrgs;
	private Boolean selectable;

	/**
	 * @param idIn test
	 * @param fqdnIn test
	 * @param ipIn test
	 * @param enabledIn test
	 * @param allOrgsIn test
	 * @param selectableIn test
	 */
	public SlaveItem(Long idIn, String fqdnIn, String ipIn, Boolean enabledIn,
			Boolean allOrgsIn, Boolean selectableIn) {
		super();
		this.id = idIn;
		this.fqdn = fqdnIn;
		this.ip = ipIn;
		this.enabled = enabledIn;
		this.allOrgs = allOrgsIn;
		this.selectable = selectableIn;
	}

	/**
	 * @return test
	 */
	public Long getId() {
		return id;
	}

	/**
	 * @param idIn test
	 */
	public void setId(Long idIn) {
		this.id = idIn;
	}

	/**
	 * @return test
	 */
	public String getFqdn() {
		return fqdn;
	}

	/**
	 * @param fqdnIn test
	 */
	public void setFqdn(String fqdnIn) {
		this.fqdn = fqdnIn;
	}

	/**
	 * @return test
	 */
	public String getIp() {
		return ip;
	}

	/**
	 * @param ipIn test
	 */
	public void setIp(String ipIn) {
		this.ip = ipIn;
	}

	/**
	 * @return test
	 */
	public Boolean getEnabled() {
		return enabled;
	}

	/**
	 * @param enabledIn test
	 */
	public void setEnabled(Boolean enabledIn) {
		this.enabled = enabledIn;
	}

	/**
	 * @return test
	 */
	public Boolean getAllOrgs() {
		return allOrgs;
	}

	/**
	 * @param allOrgsIn test
	 */
	public void setAllOrgs(Boolean allOrgsIn) {
		this.allOrgs = allOrgsIn;
	}

	/**
	 * @return test
	 */
	public Boolean getSelectable() {
		return selectable;
	}

	/**
	 * @param selectableIn test
	 */
	public void setSelectable(Boolean selectableIn) {
		this.selectable = selectableIn;
	}
}
