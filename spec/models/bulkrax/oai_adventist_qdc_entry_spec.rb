# frozen_string_literal: true

require "spec_helper"
require "bulkrax/entry_spec_helper"

RSpec.describe Bulkrax::OaiAdventistQdcEntry do
  describe "#build_metadata" do
    subject(:entry) do
      Bulkrax::EntrySpecHelper.entry_for(
        entry_class: described_class,
        identifier: identifier,
        data: data,
        parser_class_name: "Bulkrax::OaiAdventistQdcParser",
        parser_fields: {
          "base_url" => "http://oai.adventistdigitallibrary.org/OAI-script"
        }
      )
    end

    let(:identifier) { "20121637" }
    # rubocop:disable Metrics/LineLength
    let(:data) do
      %(<?xml version="1.0" encoding="UTF-8"?>
        <OAI-PMH xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/ http://www.openarchives.org/OAI/2.0/OAI-PMH.xsd">
          <responseDate>2023-02-01T20:41:11Z</responseDate>
          <request verb="GetRecord">http://oai.adventistdigitallibrary.org/OAI-script?identifier=#{identifier}&amp;metadataPrefix=oai_adl&amp;verb=GetRecord</request>
          <GetRecord>
            <record>
              <header>
                <identifier>#{identifier}</identifier>
                <datestamp>2022-12-15T05:09:20Z</datestamp>
                <setSpec>adl:book</setSpec>
              </header>
              <metadata>
                <oai_adl>
                  <abstract>This tract is part of a series of testimonies written by Ellen White and published by the Seventh-day Adventist Church from 1855 to 1909.</abstract>
                  <aark_id>20121637</aark_id>
                  <identifier>b10134815_06; W11 .T5</identifier>
                  <creator>White, Ellen Gould Harmon, 1827-1915</creator>
                  <title>Testimony for the Church: Number 7</title>
                  <resource_type>Book</resource_type>
                  <date_created>1862-01-01</date_created>
                  <language>English</language>
                  <extent>no. in v. ; 15 cm.</extent>
                  <source>Center for Adventist Research</source>
                  <geocode>42.323991, -85.190425</geocode>
                  <place_of_publication>Battle Creek, Michigan, USA</place_of_publication>
                  <part_of>John N. Andrews Library Collection</part_of>
                  <publisher>Steam Press of the Seventh-Day Adventist Publishing Association</publisher>
                  <rights_statement>No Copyright – United States</rights_statement>
                  <subject>Charity -- Dress Reform -- Spiritualism; Civil War, 1861-1865 -- Slavery; History; Visions -- Censures; White, Ellen Gould Harmon, 1827-1915</subject>
                  <work_type>PublishedWork</work_type>
                 </oai_adl>
               </metadata>
            </record>
          </GetRecord>
        </OAI-PMH>)
    end

    # rubocop:enable Metrics/LineLength
    it "assigns the factory class" do
      entry.build_metadata

      expect(entry.factory_class).to eq(PublishedWork)
      expect(entry.parsed_metadata.fetch('title')).to eq(["Testimony for the Church: Number 7"])
      expect(entry.parsed_metadata.fetch('part')).to eq(["John N. Andrews Library Collection"])
    end
  end
end
