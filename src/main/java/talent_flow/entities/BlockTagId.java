package talent_flow.entities;

import java.io.Serializable;
import java.util.Objects;
import java.util.UUID;

public class BlockTagId implements Serializable {

    private UUID blockId;
    private UUID tagId;

    public BlockTagId() {}

    public BlockTagId(UUID blockId, UUID tagId) {
        this.blockId = blockId;
        this.tagId = tagId;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof BlockTagId)) return false;
        BlockTagId that = (BlockTagId) o;
        return Objects.equals(blockId, that.blockId) &&
               Objects.equals(tagId, that.tagId);
    }

    @Override
    public int hashCode() {
        return Objects.hash(blockId, tagId);
    }
}