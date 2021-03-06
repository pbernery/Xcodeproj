module Xcodeproj
  class Project
    module Object

      # Apparently a proxy for a reference object which might belong another
      # project contained in the same workspace of the project document.
      #
      # This class is used for referencing the products of another project.
      #
      class PBXReferenceProxy < AbstractObject

        # @return [String] the path of the referenced filed.
        #
        attribute :path, String

        # @return [String] the file type of the referenced filed.
        #
        attribute :file_type, String

        # @return [PBXContainerItemProxy] the proxy to the project that
        #   contains the object.
        #
        has_one :remote_ref, PBXContainerItemProxy

        # @return [String] the source tree for the path of the reference.
        #
        # E.g. "BUILT_PRODUCTS_DIR"
        #
        attribute :source_tree, String

      end
    end
  end
end

