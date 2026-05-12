package com.apollo

import androidx.room.ColumnInfo
import androidx.room.Entity
import androidx.room.PrimaryKey
import androidx.room.Dao
import androidx.room.Insert
import androidx.room.Query
import androidx.room.Database
import androidx.room.RoomDatabase

@Entity(tableName = "nodes")
data class NodeEntity(
    @PrimaryKey val id: String,
    @ColumnInfo(name = "type") val type: String,
    @ColumnInfo(name = "hash") val hash: String
)

@Dao
interface NodeDao {
    @Query("SELECT * FROM nodes")
    fun getAll(): List<NodeEntity>

    @Insert
    fun insertAll(vararg nodes: NodeEntity)
}

@Database(entities = [NodeEntity::class], version = 1)
abstract class AppDatabase : RoomDatabase() {
    abstract fun nodeDao(): NodeDao
}
