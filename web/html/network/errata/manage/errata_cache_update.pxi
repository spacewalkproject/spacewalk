<?xml version="1.0" encoding="utf8"?>
<pxt-passthrough>

  <pxt-use class="Sniglets::ErrataEditor" />

<rhn-if-errata-package-list-modified>
    <div class="page-summary">
<pxt-formvar>
    <span style="color: green">
      <p>The list of packages associated with this errata has been modified recently.</p>
      <p>These changes will not immediately be available to systems to which this errata applies.  The changes will become available approximately 10 minutes after they are made.  Or, you can <a href="/network/errata/manage/edit.pxt?pxt:trap=rhn:update_errata_cache&amp;eid={formvar:eid}">commit your changes immediately</a> when you are finished editing this errata.</p>
    </span>
</pxt-formvar>
    </div>
</rhn-if-errata-package-list-modified>

</pxt-passthrough>